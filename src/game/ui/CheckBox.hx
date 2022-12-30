package ui;

import s2d.Interactive;
import h2d.Object;
import h2d.Bitmap;
import h2d.Text;

class CheckBox extends Object
{
	var interactive : Interactive;
	var t : Text;
	var box : h2d.Bitmap;
	var select : h2d.Bitmap;

	public var textWidth(default, set) : Null<Float>;
	function set_textWidth(w : Null<Float>) : Float
	{
		if (w != null)
		{
			box.x = w + 20;
			t.maxWidth = w;
		} else
		{
			box.x = t.textWidth + 20;
			t.maxWidth = null;
		}
		interactive.width = box.x + box.width;
		return textWidth = w;
	}

	public var fontStyle(default, set) : EFontStyle;
	function set_fontStyle(f : EFontStyle) : EFontStyle
	{
		t.font = Assets.font(fontStyle = f);
		@:privateAccess box.y = (t.font.lineHeight - box.height) / 2;
		interactive.height = t.font.lineHeight * 3 / 4;
		interactive.y = (t.font.lineHeight - interactive.height) / 3;
		return fontStyle;
	}

	public var text(get, set) : String;
	inline function get_text() : String return t.text;
	function set_text(text : String) : String
	{
		t.text = text;
		if (textWidth == null)
		{
			box.x = t.textWidth + 20;
			interactive.width = box.x + box.width;
		}
		return t.text;
	}

	public var id(default, set) : String;
	function set_id(v)
	{
		id = name = v;
		return id;
	}

	public var checked(get, set) : Bool;
	inline function get_checked() : Bool return select.visible;
	function set_checked(checked : Bool) : Bool
	{
		select.visible = checked;
		return checked;
	}

	public var onFocus(never, set) : hxd.Event->Void;
	function set_onFocus(onFocus : hxd.Event->Void) : hxd.Event->Void
	{
		return interactive.onFocus = onFocus;
	}

	public var onFocusLost(never, set) : hxd.Event->Void;
	function set_onFocusLost(onFocusLost : hxd.Event->Void) : hxd.Event->Void
	{
		return interactive.onFocusLost = onFocusLost;
	}

	public function new(size : Float, fontStyle : EFontStyle = Regular, ca : ControllerAccess<GameAction>, ?p)
	{
		super(p);

		interactive = new Interactive(0, 0, ca, this);
		interactive.onClick = (_) ->
		{
			checked = !checked;
			onChange();
		}
		interactive.onOver = (_) ->
		{
			interactive.focus();
		}

		t = new Text(Assets.font(fontStyle), this);
		t.textColor = 0;

		// TODO box = Assets.ui.getNamedBitmap('CheckBox', this);
		box = new Bitmap(h2d.Tile.fromColor(0x404040), this);
		box.width = box.height = size;

		// TODO select = Assets.ui.getNamedBitmap('CheckBox_Select', this);
		select = new Bitmap(h2d.Tile.fromColor(0xCCCCCC), box);
		select.width = select.height = size - 8;
		select.x = (box.width - select.width) / 2;
		select.y = (box.height - select.height) / 2;
		select.visible = false;

		interactive.width = box.x + box.width;

		this.fontStyle = fontStyle;
	}

	override function onAdd()
	{
		super.onAdd();
		Lang.langUpdateDelegates.push(updateText);
	}

	function updateText()
	{
		fontStyle = fontStyle;
		if (id != null)
			text = Lang.t.get(id);
	}

	override function onRemove()
	{
		super.onRemove();
		Lang.langUpdateDelegates.remove(updateText);
	}

	/**
		Sent when the `CheckBox.selected` state is changed.
		Can be triggered both by user interaction (when checkbox is enabled) and from the software side by changing `selected` directly.
	**/
	public dynamic function onChange() {}
}