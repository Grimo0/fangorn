package assets;

import dn.data.GetText;

class Lang
{
	static var _initDone = false;
	public static var CUR : ELanguage = null;
	public static var t : GetText;

	public static var langUpdateDelegates = new Array<Void->Void>();

	public static function init(?lid : ELanguage)
	{
		if (_initDone)
			return;

		t = new GetText();

		CUR = lid == null ? getELanguage(getSystemLang()) : lid;
	}

	public static function load(lid : ELanguage)
	{
		var old = CUR;
		init(lid);
		if (old != CUR)
		{
			var id = getLanguageId(CUR);
			var res = try hxd.Res.load('lang/$id.po')
			catch (e)
			{
				CUR = English;
				id = getLanguageId(CUR);
				hxd.Res.load('lang/$id.po');
			}

			t.readPo(res.entry.getBytes());

			for (fun in langUpdateDelegates)
			{
				fun();
			}
		}
	}

	public static inline function untranslated(str : Dynamic) : LocaleString
	{
		load(CUR);
		return t.untranslated(str);
	}

	/**
		Return a simple language code, depending on current System setting (eg. "en", "fr", "de" etc.). If something goes wrong, this returns "en".
		See: https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
	**/
	public static function getSystemLang() : String
	{
		try
		{
			var code = hxd.System.getLocale();
			if (code.indexOf("-") >= 0)
				code = code.substr(0, code.indexOf("-"));
			return code.toLowerCase();
		}
		catch (_)
			return "en";
	}

	/**
		Return a simple language code (eg. "en", "fr", "de" etc.).
		See: https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
	**/
	public static inline function getLanguageId(type : ELanguage) : String
	{
		return switch type
		{
			case French: "fr";
			case English: "en";
			default: null;
		}
	}

	/**
		From a simple language code (eg. "en", "fr", "de" etc.) return the associated ELanguage.
		See: https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
	**/
	public static inline function getELanguage(code : String) : ELanguage
	{
		return switch code
		{
			case "fr": French;
			case "en": English;
			default: null;
		}
	}

	public static inline function getLanguageName(type : ELanguage) : LocaleString
	{
		return switch type
		{
			case French: Lang.t.untranslated("Français");
			case English: Lang.t.untranslated("English");
		}
	}

	public static inline function getTextSize(type : ETextSize) : LocaleString
	{
		return switch type
		{
			case Regular: Lang.t._("Regular||@Text size");
			case Large: Lang.t._("Large||@Text size");
		}
	}
}