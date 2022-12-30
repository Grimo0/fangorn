package tools;

import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.Tools;
using Lambda;
using haxe.macro.TypedExprTools;

class MacroTools
{
	/**
		Generate a string with a version number based on  the date.
	**/
	public static macro function getBuildDate()
	{
		var date = Date.now();
		var buildTime = Math.floor((Date.now().getTime() - Date.fromString('2022-03-30').getTime()) / 100000); // Change every 100 seconds
		return macro $v{buildTime};
	}

	/**
		Automatically assigns parameters of method to local variables with the same name.
	**/
	macro static public function initLocals() : Expr
	{
		// Grab the variables accessible in the context the macro was called.
		var locals = Context.getLocalVars();
		var fields = Context.getLocalClass().get().fields.get();

		var exprs : Array<Expr> = [];
		for (local in locals.keys())
		{
			if (fields.exists(function(field) return field.name == local))
			{
				exprs.push(macro this.$local = $i{local});
			} else
			{
				Context.warning(Context.getLocalClass() + " has no field " + local, Context.currentPos());
			}
		}
		// Generates a block expression from the given expression array
		return macro $b{exprs};
	}

	/**
		Display the local variables in the following form
		CLASS
		 |- VAR1:
		   |- VAR1=...
		 |- VAR2=...
	**/
	macro static public function rprintLocalVars() : Expr
	{
		var exprs : Array<Expr> = [];

		function _crawl(that : Expr, v : haxe.macro.Type.ClassField, depth = 0)
		{
			var indent = '';
			for (i in 0...depth - 1)
				indent += '  ';
			indent = indent + (depth > 0 ? ' |- ' : '');
			if (v.expr() == null)
				return;
			switch v.type
			{
				case haxe.macro.Type.TAbstract(_, _):
				case haxe.macro.Type.TEnum(_):
				case haxe.macro.Type.TDynamic(_):

				case haxe.macro.Type.TInst(t, params):
					var fields = t.get().fields.get();
					if (fields.length == 0)
					{
						exprs.push(macro out += '\n' + $v{indent + v.name} + ': {}');
					} else
					{
						exprs.push(macro out += '\n' + $v{indent + v.name} + ':');
						for (field in fields)
						{
							var fname = field.name;
							var t = macro $that.$fname;
							_crawl(t, field, depth + 1);
						}
					}
					return;

				case haxe.macro.Type.TAnonymous(a):
					var fields = a.get().fields;
					if (fields.length == 0)
					{
						exprs.push(macro out += '\n' + $v{indent + v.name} + ': {}');
					} else
					{
						exprs.push(macro out += '\n' + $v{indent + v.name} + ':');
						for (field in fields)
						{
							var fname = field.name;
							var t = macro $that.$fname;
							_crawl(t, field, depth + 1);
						}
					}
					return;

				case _:
					return;
			}
			exprs.push(macro out += '\n' + $v{indent + v.name} + '=' + Std.string($that));
		}

		// Grab the variables accessible in the context the macro was called.
		var localClass = Context.getLocalClass().get();
		var fields = localClass.fields.get();
		if (fields.length == 0)
		{
			exprs.push(macro var out = '\n' + $v{localClass.name} + ': {}');
		} else
		{
			exprs.push(macro var out = '\n' + $v{localClass.name} + ':');
			for (field in fields)
			{
				var fname = field.name;
				var that = macro this.$fname;
				_crawl(that, field, 1);
			}
		}
		exprs.push(macro out);

		return macro $b{exprs};
	}

	/**
		Create an anonymous structure using the Json on the specified path
	**/
	public static macro function loadJson(filePath : String)
	{
		return try
		{
			var fileContent = File.getContent(filePath);
			var json = haxe.Json.parse(fileContent);
			macro $v{json};
		} catch (e)
		{
			Context.fatalError('Failed to load json: $e', Context.currentPos());
		}
	}

	/**
		Create a map with all atlas found in `resSubDir` set by their name.
	**/
	public static macro function getAtlasMap(resSubDir : String) : ExprOf<Map<String, dn.heaps.slib.SpriteLib>>
	{
		var pos = Context.currentPos();

		var resDir = haxe.macro.Context.definedValue("resourcesPath");
		resDir = (resDir == null ? "res" : resDir) + "/";
		var path = resDir + resSubDir;
		if (!FileSystem.exists(path) || !FileSystem.isDirectory(path))
			Context.fatalError('Folder $resSubDir wasn\'t found inside Heaps res folder.', pos);

		var m : Array<Expr> = [];

		for (fName in FileSystem.readDirectory(path))
		{
			var p = new Path(fName);
			if (p.ext != 'atlas') continue;
			p.ext = null;
			m.push(macro $v{p.toString()} => dn.heaps.assets.Atlas.load($v{'$resSubDir/$fName'}));
		}
		return macro $a{m};
	}

	/**
		Get a map of the of the sound in `resSubDir` set by their name. 
		For sounds that ends with _XX with XX a number, a `GroupSound` is created instead of a `hxd.res.Sound`.
	**/
	public static macro function getSoundMap(resSubDir : String) : ExprOf<Map<String, hxd.res.Sound>>
	{
		var pos = Context.currentPos();

		var resDir = haxe.macro.Context.definedValue("resourcesPath");
		resDir = (resDir == null ? "res" : resDir) + "/";
		var rootPath = resDir + resSubDir;
		if (!FileSystem.exists(rootPath) || !FileSystem.isDirectory(rootPath))
			Context.fatalError('Folder "$resSubDir" wasn\'t found inside res folder.', pos);

		var randomSerieReg = ~/_[0-9]+$/gi;
		var supportedExts = ["wav", "ogg", "mp3"];
		function addFilesFromDir(dirPath : String, subDirName : String, ?exts : Array<String>) : Array<Expr>
		{
			var m : Array<Expr> = [];

			// Add all sounds and groups to the list & do a recursive call on subfolders
			var soundsPath : Array<Path> = [];
			var groups : Array<String> = [];
			for (fName in FileSystem.readDirectory('$resDir$dirPath/$subDirName'))
			{
				var p = new Path(subDirName.length > 0 ? '$subDirName/$fName' : fName);
				if (FileSystem.isDirectory('$resDir$dirPath/$p'))
				{
					var subFiles = addFilesFromDir('$dirPath', '$p', exts);
					for (sound in subFiles)
					{
						m.push(sound);
					}
					continue;
				}

				if (p.ext == null) continue;
				p.ext = p.ext.toLowerCase();
				if (exts != null && exts.indexOf(p.ext) >= 0) continue;
				soundsPath.push(p);

				if (randomSerieReg.match(p.file))
				{
					var generalId = randomSerieReg.matchedLeft();
					if (!groups.contains(generalId))
						groups.push(generalId);
				}
			}

			// Add groups and their sounds to the map
			for (group in groups)
			{
				var groupReg = new EReg('${group}_[0-9]+$', 'i');
				var serie : Array<Expr> = [];
				for (i in 0...soundsPath.length)
				{
					var p = soundsPath[i];
					if (p == null) continue;
					if (!groupReg.match(p.file)) continue;
					var sound = macro hxd.Res.load($v{'$dirPath/$p'}).to(hxd.res.Sound);
					p.ext = null;
					var name = cleanUpIdentifier('$p');
					m.push(macro $v{name} => $sound);
					serie.push(macro $sound);
					soundsPath[i] = null;
				}

				var id = cleanUpIdentifier(subDirName.length > 0 ? '$subDirName/$group' : group);
				m.push(macro $v{id} => @:privateAccess
					{
						var path = $v{id};
						var res : snd.GroupSound = hxd.Res.loader.cache.get(path);
						if (res == null)
						{
							var old = hxd.res.Loader.currentInstance;
							hxd.res.Loader.currentInstance = hxd.Res.loader;
							var v = $a{serie};
							res = Type.createInstance(snd.GroupSound, [v[0].entry]);
							res.serie = $a{serie};
							hxd.res.Loader.currentInstance = old;
							hxd.Res.loader.cache.set(path, res);
						} else
						{
							if (hxd.impl.Api.downcast(res, snd.GroupSound) == null)
								throw path + " has been reintrepreted from " + Type.getClass(res) + " to " + snd.GroupSound;
						}
						res;
					});
			}

			// Add the last sounds to the map
			for (i in 0...soundsPath.length)
			{
				var p = soundsPath[i];
				if (p == null) continue;
				var sound = macro hxd.Res.load($v{'$dirPath/$p'}).to(hxd.res.Sound);
				p.ext = null;
				var name = cleanUpIdentifier('$p');
				m.push(macro $v{name} => $sound);
			}

			return m;
		}

		var m = addFilesFromDir(resSubDir, '', supportedExts);

		if (m.length == 0)
			Context.warning('No compatible sounds found in folder $rootPath.', pos);

		return macro $a{m};
	}

	static var CLEANUP_REG = ~/[^A-Za-z0-9_\/.]+/g;
	static var NON_LEADING_NUMBERS = ~/[0-9]+([A-Za-z_.])/gi;
	static inline function cleanUpIdentifier(i : String)
	{
		i = CLEANUP_REG.replace(i, "_");
		i = NON_LEADING_NUMBERS.replace(i, "$1");
		return i;
	}
}