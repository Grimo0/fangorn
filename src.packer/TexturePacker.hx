import haxe.io.Path;
import hx.concurrent.thread.ThreadPool;
import sys.io.Process;
import sys.io.File;
import haxe.io.Eof;
import sys.FileSystem;

typedef PackJson = {
	pot : Bool,
	paddingX : Int,
	paddingY : Int,
	edgePadding : Bool,
	rotation : Bool,
	maxWidth : Int,
	maxHeight : Int,
	stripWhitespaceX : Bool,
	stripWhitespaceY : Bool,
	filterMin : String,
	filterMag : String,
	fast : Bool,
	combineSubdirectories : Bool,
	flattenPaths : Bool,
	limitMemory : Bool,
	ignoreBlankImages : Bool,
	scale : Array<Float>
}

class TexturePacker extends Packer {
	var threadPool = new ThreadPool(3);

	public function new() {
		super();
	}

	override function pack() {
		final packListPath = new Path('art/packList.txt').toString();
		
		if (!FileSystem.exists(packListPath)) {
			error(null, 'packList.txt not found ($packListPath)');
			return;
		}
		
		print('Parsing packList.txt ($packListPath)...\n##############');
		#if resolution4k
		final outputDir = new Path('res/atlas4k/').toString();
		#else
		final outputDir = new Path('res/atlas/').toString();
		#end
		var packList = File.getContent(packListPath);
		for (line in packList.split('\n')) {
			if (emptyStrReg.match(line))
				continue;

			final inputDir = new Path('art/$line/').toString();
			if (!FileSystem.exists(inputDir)) {
				error(packListPath, 'Can\'t find $inputDir.');
				continue;
			}

			texturePackerProcess(true, inputDir, outputDir, line);
		}

		while (!threadPool.awaitCompletion(1000)) {}
	}

	function texturePackerProcess(testDate : Bool, inputDir : String, outputDir : String, packName : String) {
		final packerCmd = 'java -cp tools/runnable-texturepacker.jar com.badlogic.gdx.tools.texturepacker.TexturePacker';
		if (!testDate
			|| !FileSystem.exists('$outputDir$packName.atlas')
			|| FileSystem.stat('$outputDir$packName.atlas').mtime.getTime() < FileSystem.stat(inputDir).mtime.getTime()) {
			var launchProcess = () -> {
				var timeBefore = Sys.time();

				#if resolution4k
				var packJson : String = null;
				if (FileSystem.exists('${inputDir}pack.json')) {
					packJson = File.getContent('${inputDir}pack.json');
					var json : PackJson = haxe.Json.parse(packJson);
					if (json.scale != null) {
						// Update the json
						json.scale[0] = 1;
						json.maxWidth *= 2;
						json.maxHeight *= 2;
						File.saveContent('${inputDir}pack.json', haxe.Json.stringify(json, '\t'));
					} else packJson = null;
				}
				#end
	
				var process : Process = null;
				try {
					process = new Process('$packerCmd "$inputDir" "$outputDir" "$packName"');
	
					#if verbose
					print('\n* Start packing $packName');
					do {
						try {
							while (true)
								print('\n  $packName: ' + process.stdout.readLine());
						} catch (e:Eof) {}
					} while (process.exitCode(false) == null);
					#end
					
					if (process.exitCode() != 0) {
						try {
							while (true)
								error('$outputDir$packName.atlas', process.stderr.readLine());
						} catch (e:Eof) {}
					}
				} catch (e) {
					error('$outputDir$packName.atlas', e.toString());
				}
				if (process != null)
					process.close();
				
				#if resolution4k
				// Set the previous json back
				if (packJson != null)
					File.saveContent('${inputDir}pack.json', packJson);
				#end
	
				var timeSpent = Sys.time() - timeBefore;
				print('\n* $packName packed in ${Std.int(timeSpent * 100) / 100}s');
			};

			threadPool.submit(function(ctx:ThreadContext) {
				launchProcess();
			});
		} 
		#if verbose
		else
			print('\n* $packName already up to date');
		#end
	}
}
