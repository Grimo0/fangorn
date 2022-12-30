package tools;

import sys.FileSystem;
import sys.io.File;
import haxe.zip.Entry;

class ZipTools
{
	/**
	 * Add an entry for the file specified by the path to the list.
	 * @param path The path to a file
	 */
	static function addEntry(path : String, entries : List<Entry>)
	{
		if (!FileSystem.exists(path)) return;
		var bytes : haxe.io.Bytes = haxe.io.Bytes.ofData(File.getBytes(path).getData());
		var entry : Entry =
			{
				fileName: haxe.io.Path.withoutDirectory(path), // file.toString(),
				fileSize: bytes.length,
				fileTime: Date.now(),
				compressed: false,
				dataSize: FileSystem.stat(path).size, // 0,
				data: bytes,
				crc32: haxe.crypto.Crc32.make(bytes)
			};
		haxe.zip.Tools.compress(entry, 9);
		entries.push(entry);
	}

	/**
	 * Recursive read a directory, add the file entries to the list.
	 */
	static function getEntries(dir : String, entries : List<Entry>, inDir : Null<String> = null)
	{
		if (inDir == null) inDir = dir;
		if (!FileSystem.exists(dir)) return entries;
		for (file in FileSystem.readDirectory(dir))
		{
			var path = haxe.io.Path.join([dir, file]);
			if (FileSystem.isDirectory(path))
			{
				getEntries(path, entries, inDir);
			} else
			{
				addEntry(path, entries);
			}
		}
		return entries;
	}

	public static function zip(outputPath : String, ?folders : Array<String>, ?files : Array<String>)
	{
		var entries = new List<Entry>();
		if (folders != null)
		{
			for (f in folders)
			{
				getEntries(f, entries);
			}
		}

		if (files != null)
		{
			for (f in files)
			{
				addEntry(f, entries);
			}
		}

		// create the output file
		var out = File.write(outputPath, true);
		// write the zip file
		var zip = new haxe.zip.Writer(out);
		zip.write(entries);
		out.close();
	}
}