import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.thread.Mutex;

class Packer {
	var stdout = Sys.stdout();
	var stderr = Sys.stderr();
	var outputMutex = new Mutex();

	final emptyStrReg = ~/^\s*$/i;

	public function new() {}

	public function run() {
		var timeBefore = Sys.time();

		pack();

		var timeSpent = Sys.time() - timeBefore;
		print('\n##############\nTotal time: ${Std.int(timeSpent * 100) / 100}s\n');
	}

	inline function copyFile(inFile : String, outFile : String) {
		if (!FileSystem.exists(outFile)
			|| FileSystem.stat(outFile).mtime.getTime() < FileSystem.stat(inFile).mtime.getTime()) {
			File.copy(inFile, outFile);
			print('\n* $inFile -> $outFile');
		}
	}

	function pack() {
		final args = Sys.args();

		if (args.length == 0) {
			printManual();
			return;
		}

		var i = 0;
		while (i < args.length) {
			switch args[i] {
				case "-D":
					var exts = args[++i].split(',');
					var inDir = exts.shift();
					var outDir = '';
					if (i < args.length - 1 && args[i + 1].indexOf("-") != 0) {
						outDir = args[++i];
						FileSystem.createDirectory('res/$outDir');
					}

					if (exts.length == 0) {
						for (s in FileSystem.readDirectory(inDir)) {
							copyFile('$inDir/$s', 'res/$outDir/$s');
						}
					} else {
						for (s in FileSystem.readDirectory(inDir)) {
							var ext = Path.extension(s);
							if (exts.contains(ext))
								copyFile('$inDir/$s', 'res/$outDir/$s');
						}
					}

				case "-F":
					var filePath = args[++i];
					var fileName = Path.withoutDirectory(filePath);

					if (i < args.length - 1 && args[i + 1].indexOf("-") != 0) {
						var outDir = args[++i];
						copyFile(filePath, 'res/$outDir/$fileName');
					} else
						copyFile(filePath, 'res/$fileName');

				default:
					printManual();
			}
			i++;
		}
	}

	function printManual() {
		print('\nNo argument specified. Use the following:'
			+ '\n\t-D inputDir[,ext1[...]] [outputDir]\tWill copy the content of inputDir to res/outputDir'
			+ '\n\t-F pathToFile [outputDir]\tWill copy the file to res/outputDir');
	}

	inline function print(s : String) {
		outputMutex.acquire();
		stdout.writeString(s);
		outputMutex.release();
	}

	inline function error(file : String, msg : String) {
		outputMutex.acquire();
		stderr.writeString("\nERROR: " + (file != null ? file + ": " : "") + msg);
		outputMutex.release();
		Sys.exit(-1);
	}
}