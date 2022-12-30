#if hlsteam
import steam.Api;
#end

class DebugOptions extends Saved
{
	public var quickTransition = false;
	public var hotReload(default, set) = false;
	public function set_hotReload(b : Bool)
	{
		hxd.res.Resource.LIVE_UPDATE = b;
		return hotReload = b;
	}
	public var stats = false;

	public function new() {}

	public function reset()
	{
		quickTransition = false;
		hotReload = false;
		stats = false;
	}
}

class Options extends Saved
{
	public static var ME : Options;

	public var debug = new DebugOptions();

	public var fullscreen(default, set) = false;
	public function set_fullscreen(b : Bool)
	{
		App.ME.engine.fullScreen = b;
		fullscreen = b;
		trace('fullscreen set to $b');
		resolution = resolution;
		return fullscreen;
	}

	public var resolution(default, set) : Resolution;
	function set_resolution(v : Resolution) : Resolution
	{
		if (v != null)
		{
			if (resolution != null)
			{
				if (!fullscreen)
				{
					hxd.Window.getInstance().resize(v.w, v.h);
				} else
				{
					// TODO Change game resolution when in fullscreen
					/* var win = hxd.Window.getInstance();
						var scaleX = v.w / win.width;
						var scaleY = v.h / win.height;
						if (scaleX < scaleY)
							Main.ME.engine.resize(Math.floor(v.h * win.width / win.height), v.h);
						else 
							Main.ME.engine.resize(v.w, Math.floor(v.w * win.height / win.width)); */
					// Boot.ME.s2d.scaleMode = LetterBox(v.w, v.h);
					// dn.Process.resizeAll();
				}
			}
			resolution = v;
			trace('resolution set to $v');
		}
		return resolution;
	}

	public var language(default, set) : ELanguage = null;
	public function set_language(l : ELanguage)
	{
		if (l != language && Assets.initDone)
			Lang.load(l);
		trace('language set to $l');
		return language = l;
	}

	public var textSize(default, set) : ETextSize = Regular;
	public function set_textSize(s : ETextSize)
	{
		textSize = s;
		if (Assets.initDone)
			Assets.loadFonts();
		trace('textSize set to $s');
		return textSize;
	}
	public var fontSet(default, set) : EFontSet = Default;
	public function set_fontSet(f : EFontSet)
	{
		fontSet = f;
		if (Assets.initDone)
			Assets.loadFonts();
		trace('fontSet set to $f');
		return fontSet;
	}

	public var masterVolume(default, set) : Float = 1.;
	public function set_masterVolume(v : Float)
	{
		trace('masterVolume set to $v');
		return masterVolume = SoundManager.ME.masterVolume = v;
	}
	public var musicVolume(default, set) : Float = .8;
	public function set_musicVolume(v : Float)
	{
		trace('musicVolume set to $v');
		return musicVolume = SoundManager.ME.musicVolume = v;
	}
	public var soundVolume(default, set) : Float = 1.;
	public function set_soundVolume(v : Float)
	{
		trace('soundVolume set to $v');
		return soundVolume = SoundManager.ME.soundVolume = v;
	}

	public var hue(default, set) : Float = 0.;
	public function set_hue(v : Float)
	{
		trace('hue set to $v');
		hue = v;
		App.ME.cmFilter.matrix.identity();
		App.ME.cmFilter.matrix.adjustColor({saturation: sat / 100, lightness: lightness / 100, hue: hue * Math.PI / 180, contrast: contrast / 100});
		return hue;
	}
	public var sat(default, set) : Float = 0.;
	public function set_sat(v : Float)
	{
		trace('sat set to $v');
		sat = v;
		App.ME.cmFilter.matrix.identity();
		App.ME.cmFilter.matrix.adjustColor({saturation: sat / 100, lightness: lightness / 100, hue: hue * Math.PI / 180, contrast: contrast / 100});
		return sat;
	}
	public var lightness(default, set) : Float = 0.;
	public function set_lightness(v : Float)
	{
		trace('lightness set to $v');
		lightness = v;
		App.ME.cmFilter.matrix.identity();
		App.ME.cmFilter.matrix.adjustColor({saturation: sat / 100, lightness: lightness / 100, hue: hue * Math.PI / 180, contrast: contrast / 100});
		return lightness;
	}
	public var contrast(default, set) : Float = 0.;
	public function set_contrast(v : Float)
	{
		trace('contrast set to $v');
		contrast = v;
		App.ME.cmFilter.matrix.identity();
		App.ME.cmFilter.matrix.adjustColor({saturation: sat / 100, lightness: lightness / 100, hue: hue * Math.PI / 180, contrast: contrast / 100});
		return contrast;
	}

	var defaultSave = {};

	public function new()
	{
		ME = this;
		var winInst = hxd.Window.getInstance();
		resolution = {w: winInst.width, h: winInst.height};

		#if hlsteam
		// Get default language from Steam
		var steamLang = Api.getCurrentGameLanguage();
		trace('Steam says we should speak in $steamLang');
		switch steamLang
		{
			case 'french': language = French;
			default: language = English;
		}
		#end

		// Save the value as the default
		for (f in Reflect.fields(this))
		{
			if (f == "defaultSave") continue;
			var v = Reflect.field(this, f);
			Reflect.setField(defaultSave, f, v);
		}
	}

	public function reset()
	{
		debug.reset();
		for (f in Reflect.fields(defaultSave))
		{
			var v = Reflect.field(defaultSave, f);
			Reflect.setProperty(this, f, v);
		}
	}

	public function load()
	{
		var sav = hxd.Save.load(this, 'save/options');

		fullscreen = sav.fullscreen;
		resolution = sav.resolution;
		#if hlsteam
		var steamLang = Api.getCurrentGameLanguage();
		if (steamLang == null)
			language = sav.language;
		#else
		language = sav.language;
		#end
		textSize = sav.textSize;
		fontSet = sav.fontSet;
		masterVolume = sav.masterVolume;
		musicVolume = sav.musicVolume;
		soundVolume = sav.soundVolume;
		hue = sav.hue;
		sat = sav.sat;
		lightness = sav.lightness;
		contrast = sav.contrast;

		#if !master
		if (sav.debug != null)
			debug = sav.debug;
		#end
	}

	public function save()
	{
		if (!sys.FileSystem.exists('save'))
			sys.FileSystem.createDirectory('save');
		hxd.Save.save(this, 'save/options');
	}

	public function rprint() : String
	{
		return MacroTools.rprintLocalVars();
	}

	#if hlimgui
	public function imGuiDebugFields()
	{
		var natArray = new hl.NativeArray<Single>(1);
		var ref : hl.Ref<Bool>;

		ref = new hl.Ref(debug.quickTransition);
		if (ImGui.checkbox("quickTransition", ref))
			debug.quickTransition = ref.get();
		ref = new hl.Ref(debug.hotReload);
		if (ImGui.checkbox("hotReload", ref))
			debug.hotReload = ref.get();
		ref = new hl.Ref(debug.stats);
		if (ImGui.checkbox("stats", ref))
		{
			debug.stats = ref.get();
			if (debug.stats)
				Console.ME.enableStats();
			else
				Console.ME.disableStats();
		}

		ImGui.separator();

		ref = new hl.Ref(fullscreen);
		if (ImGui.checkbox("fullscreen", ref))
			fullscreen = ref.get();

		var style : ImGuiStyle = ImGui.getStyle();
		var spacing = style.ItemInnerSpacing.x;
		ImGui.pushItemWidth(ImGui.calcItemWidth() - spacing * 2.0 - ImGui.getFrameHeight() * 2.0);
		if (ImGui.beginCombo("##resolution", resolution))
		{
			for (res in Resolution.list)
			{
				var isSelected = resolution == res;
				if (ImGui.selectable(res, isSelected))
					resolution = res;
				if (isSelected)
					ImGui.setItemDefaultFocus();
			}
			ImGui.endCombo();
		}
		ImGui.popItemWidth();
		ImGui.sameLine(0, spacing);
		ImGui.text("resolution");

		var style : ImGuiStyle = ImGui.getStyle();
		var spacing = style.ItemInnerSpacing.x;
		ImGui.pushItemWidth(ImGui.calcItemWidth() - spacing * 2.0 - ImGui.getFrameHeight() * 2.0);
		if (ImGui.beginCombo("##language", language.getName()))
		{
			for (lang in ELanguage.createAll())
			{
				var isSelected = language == lang;
				if (ImGui.selectable(lang.getName(), isSelected))
					language = lang;
				if (isSelected)
					ImGui.setItemDefaultFocus();
			}
			ImGui.endCombo();
		}
		ImGui.popItemWidth();
		ImGui.sameLine(0, spacing);
		ImGui.text("language");

		ImGui.pushItemWidth(ImGui.calcItemWidth() - spacing * 2.0 - ImGui.getFrameHeight() * 2.0);
		if (ImGui.beginCombo("##textSize", textSize.getName()))
		{
			for (size in ETextSize.createAll())
			{
				var isSelected = textSize == size;
				if (ImGui.selectable(size.getName(), isSelected))
					textSize = size;
				if (isSelected)
					ImGui.setItemDefaultFocus();
			}
			ImGui.endCombo();
		}
		ImGui.popItemWidth();
		ImGui.sameLine(0, spacing);
		ImGui.text("textSize");

		ImGui.pushItemWidth(ImGui.calcItemWidth() - spacing * 2.0 - ImGui.getFrameHeight() * 2.0);
		if (ImGui.beginCombo("##fontSet", fontSet.getName()))
		{
			for (set in EFontSet.createAll())
			{
				var isSelected = fontSet == set;
				if (ImGui.selectable(set.getName(), isSelected))
					fontSet = set;
				if (isSelected)
					ImGui.setItemDefaultFocus();
			}
			ImGui.endCombo();
		}
		ImGui.popItemWidth();
		ImGui.sameLine(0, spacing);
		ImGui.text("fontSet");

		ImGui.pushItemWidth(ImGui.getContentRegionAvail().x);

		natArray[0] = masterVolume;
		if (ImGui.sliderFloat('##masterVolume', natArray, 0., 1., 'masterVolume %.1f'))
			masterVolume = natArray[0];
		natArray[0] = musicVolume;
		if (ImGui.sliderFloat('##musicVolume', natArray, 0., 1., 'musicVolume %.1f'))
			musicVolume = natArray[0];
		natArray[0] = soundVolume;
		if (ImGui.sliderFloat('##soundVolume', natArray, 0., 1., 'soundVolume %.1f'))
			soundVolume = natArray[0];

		natArray[0] = hue;
		if (ImGui.sliderFloat('##hue', natArray, -180, 180, 'hue %.2f'))
			hue = natArray[0];
		natArray[0] = sat;
		if (ImGui.sliderFloat('##sat', natArray, -100, 100, 'sat %.2f'))
			sat = natArray[0];
		natArray[0] = lightness;
		if (ImGui.sliderFloat('##lightness', natArray, -100, 100, 'bright %.2f'))
			lightness = natArray[0];
		natArray[0] = contrast;
		if (ImGui.sliderFloat('##contrast', natArray, -100, 100, 'contrast %.2f'))
			contrast = natArray[0];

		ImGui.popItemWidth();
	}
	#end
}