package ui;

import s2d.Interactive;
import hxd.Event;
import h2d.Object;
import h2d.Text;

@:access(ui.Dropdown)
class DropdownInteractive extends Interactive
{
	var dropdown : Dropdown;

	public function new(width, height, ca : ControllerAccess<GameAction>, dropdown : Dropdown)
	{
		super(width, height, ca, dropdown);
		this.dropdown = dropdown;
	}

	override function handleEvent(e : Event)
	{
		super.handleEvent(e);
		if (e.kind == EOver && scene.getFocus() != dropdown.dropdown.interactive)
		{
			focus();
		} else if (e.kind != EMove && e.kind != ECheck && e.kind != EFocus && e.kind != EFocusLost)
			e.cancel = true;
		e.propagate = true;
	}
}

class Dropdown extends h2d.Object
{
	var interactive : DropdownInteractive;
	var t : Text;

	public var textWidth(default, set) : Null<Float>;
	function set_textWidth(w : Null<Float>) : Null<Float>
	{
		if (w == null)
		{
			dropdown.x = 0;
		} else
		{
			dropdown.x = w + 20;
		}
		interactive.width = dropdown.x + dropdown.outerWidth;
		t.maxWidth = w;
		return textWidth = w;
	}

	public var fontStyle(default, set) : EFontStyle;
	function set_fontStyle(f : EFontStyle) : EFontStyle
	{
		t.font = Assets.font(fontStyle = f);
		@:privateAccess dropdown.y = (t.font.lineHeight - dropdown.outerHeight) / 2;
		if (textWidth == null)
		{
			dropdown.x = t.textWidth + 20;
			interactive.width = dropdown.x + dropdown.outerWidth;
			interactive.height = t.font.lineHeight * 3 / 4;
			interactive.y = (t.font.lineHeight - interactive.height) / 3;
		}
		return fontStyle;
	}

	public var text(get, set) : String;
	inline function get_text() : String return t.text;
	function set_text(text : String) : String
	{
		t.text = text;
		if (textWidth == null)
		{
			dropdown.x = t.textWidth + 20;
			interactive.width = dropdown.x + dropdown.outerWidth;
		}
		return t.text;
	}

	public var id(default, set) : String;
	function set_id(v)
	{
		id = name = v;
		return id;
	}

	var dropdown : h2d.Dropdown;

	public var selectedItem(get, set) : Int;
	inline function get_selectedItem() return dropdown.selectedItem;
	inline function set_selectedItem(v) return dropdown.selectedItem = v;

	public var onChange(never, set) : Object->Void;
	function set_onChange(onChange : Object->Void) : Object->Void
	{
		return dropdown.onChange = (s : Object) ->
		{
			onChange(s);
		};
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

	public var width(get, set) : Int;
	inline function get_width() : Int return dropdown.minWidth;
	inline function set_width(width : Int) : Int
	{
		dropdown.minWidth = width;
		interactive.width = dropdown.x + dropdown.outerWidth;
		return width;
	}

	public var height(get, set) : Int;
	inline function get_height() : Int return dropdown.minHeight;
	inline function set_height(height : Int) : Int
	{
		dropdown.minHeight = height;
		@:privateAccess dropdown.y = (t.font.lineHeight - dropdown.outerHeight) / 2;
		interactive.height = t.font.lineHeight * 3 / 4;
		interactive.y = (t.font.lineHeight - interactive.height) / 3;
		return height;
	}

	public function new(wid : Int, fontStyle : EFontStyle = Regular, ca : ControllerAccess<GameAction>, ?p : h2d.Object)
	{
		super(p);

		t = new Text(Assets.font(fontStyle), this);
		t.textColor = 0;

		dropdown = new h2d.Dropdown(this);
		dropdown.minWidth = wid;
		dropdown.backgroundTile = h2d.Tile.fromColor(0x404040);
		dropdown.tileOverItem = h2d.Tile.fromColor(0x808080);
		dropdown.dropdownList.overflow = Scroll;
		// TODO dropdown.tileArrow = Assets.ui.getTile('Dropdown_Arrow');
		// TODO dropdown.tileArrowOpen = Assets.ui.getTile('Dropdown_ArrowOpen);
		@:privateAccess dropdown.y = (t.font.lineHeight - dropdown.outerHeight) / 2;

		interactive = new DropdownInteractive(0, 0, ca, this);
		interactive.cursor = null;
		interactive.width = dropdown.x + dropdown.outerWidth;
		interactive.height = t.font.lineHeight * 3 / 4;
		interactive.y = (t.font.lineHeight - interactive.height) / 3;

		dropdown.onAfterReflow = () ->
		{
			@:privateAccess dropdown.y = (t.font.lineHeight - dropdown.outerHeight) / 2;
			interactive.height = t.font.lineHeight * 3 / 4;
			interactive.y = (t.font.lineHeight - interactive.height) / 3;
		}

		this.fontStyle = fontStyle;
	}

	override function syncPos()
	{
		super.syncPos();
		if (dropdown.dropdownList.parent == dropdown)
			dropdown.dropdownList.setScale(1);
		else
		{
			dropdown.dropdownList.setScale(matA);
			if (dropdown.rollUp)
				dropdown.dropdownList.maxHeight = Std.int(dropdown.dropdownList.y / matA) - 20;
			else
				dropdown.dropdownList.maxHeight = Std.int((getScene().height - dropdown.dropdownList.y) / matA) - 20;
			// Fix scrollbar position not set because it's not visible because the maxHeight was not set
			@:privateAccess dropdown.dropdownList.scrollBar.visible = dropdown.dropdownList.contentHeight > dropdown.dropdownList.maxHeight;
			dropdown.dropdownList.reflow();
		}
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

	inline public function addItem(s : Object)
	{
		dropdown.addItem(s);
	}
}