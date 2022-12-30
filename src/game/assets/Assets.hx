package assets;

import dn.heaps.slib.*;

/**
	This class centralizes all assets management (ie. art, sounds, fonts etc.)
**/
class Assets
{
	/** Fonts **/
	public static var fonts = new Map<EFontSet, Map<EFontStyle, h2d.Font>>();

	/** Main atlas **/
	public static var tiles : SpriteLib;

	/** LDtk world data **/
	public static var worldData : World;

	/** SFx & Music **/
	public static var musics : Map<String, hxd.res.Sound>;
	public static var sounds : Map<String, hxd.res.Sound>;

	static public var initDone(default, null) = false;
	public static function init()
	{
		if (initDone)
			return;
		initDone = true;

		// Fonts
		loadFonts();

		// Sprites
		loadSprites();

		// Parse castleDB JSON
		CastleDb.load(hxd.Res.data.entry.getText());

		// Hot-reloading of CastleDB
		#if debug
		hxd.Res.data.watch(function()
		{
			// Only reload actual updated file from disk after a short delay, to avoid reading a file being written
			App.ME.delayer.cancelById("cdb");
			App.ME.delayer.addS("cdb", function()
			{
				CastleDb.load(hxd.Res.data.entry.getBytes().toString());
				Const.db.reload_data_cdb(hxd.Res.data.entry.getText());
			}, 0.2);
		});
		#end

		// Hot-reloading of `const.json`
		#if debug
		hxd.Res.const.watch(function()
		{
			// Only reload actual updated file from disk after a short delay, to avoid reading a file being written
			App.ME.delayer.cancelById("constJson");
			App.ME.delayer.addS("constJson", function()
			{
				Const.db.reload_const_json(hxd.Res.const.entry.getBytes().toString());
			}, 0.2);
		});
		#end

		// LDtk init & parsing
		worldData = new World();

		// LDtk file hot-reloading
		#if debug
		var res = try hxd.Res.load(worldData.projectFilePath.substr(4)) catch (_) null; // assume the LDtk file is in "res/" subfolder
		if (res != null)
			res.watch(() ->
			{
				// Only reload actual updated file from disk after a short delay, to avoid reading a file being written
				App.ME.delayer.cancelById("ldtk");
				App.ME.delayer.addS("ldtk", function()
				{
					worldData.parseJson(res.entry.getText());
					if (Game.exists())
						Game.ME.onLdtkReload();
				}, 0.2);
			});
		#end

		// Music
		musics = MacroTools.getSoundMap('music');

		// Sounds
		sounds = MacroTools.getSoundMap('sfx');
	}

	public static function font(?set : EFontSet, style : EFontStyle) : h2d.Font
	{
		return fonts.get(set == null ? Options.ME.fontSet : set).get(style);
	}

	public static function loadFonts()
	{
		for (set in EFontSet.createAll())
		{
			var fs = new Map<EFontStyle, h2d.Font>();
			fs.set(Console, new hxd.res.BitmapFont(hxd.Res.fonts.pixica_mono_regular_12_xml.entry).toFont());
			switch set
			{
				case Default:
					fs.set(Regular, new hxd.res.BitmapFont(hxd.Res.fonts.pixel_unicode_regular_12_xml.entry).toFont());
					fs.set(Bold, new hxd.res.BitmapFont(hxd.Res.fonts.pixel_unicode_regular_12_xml.entry).toFont());

				case OpenDyslexic:
					var font = new hxd.res.BitmapFont(hxd.Res.fonts.opendyslexic3_regular_32_xml.entry).toFont().clone();
					font.resizeTo(6);
					fs.set(Regular, font);
					font = new hxd.res.BitmapFont(hxd.Res.fonts.opendyslexic3_bold_32_xml.entry).toFont().clone();
					font.resizeTo(6);
					fs.set(Bold, font);
			}
			fonts.set(set, fs);
		}
	}

	public static function loadSprites()
	{
		// Build sprite atlas directly from Aseprite file
		tiles = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.tiles.toAseprite());
	}

	/**
		Pass `tmod` value from the game to atlases, to allow them to play animations at the same speed as the Game.
		For example, if the game has some slow-mo running, all atlas anims should also play in slow-mo
	**/
	@:noUsing
	public static function update(tmod : Float)
	{
		if (Game.exists() && Game.ME.isPaused())
			tmod = 0;

		tiles.tmod = tmod;
		// <-- add other atlas TMOD updates here
	}

	/**
	 * @param align If null will be centered
	 */
	public static function getBillboardMesh(sprLib : SpriteLib, g : String, frame = 0, x = 1., y = 1., align : s3d.BillboardMesh.MeshAlign = null, ?parent : h3d.scene.Object)
	{
		var tile = sprLib.getCachedTile(g, frame);
		return s3d.BillboardMesh.createFromTile(tile, x, y, align, parent);
	}
}