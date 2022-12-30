package ui;

import s2d.Interactive;
import dn.heaps.slib.SpriteLib;
import h2d.Object;
import h2d.col.Bounds;
import dn.heaps.slib.HSprite;
import hxd.Event;

class Button extends Interactive
{
	public var bg(default, null) : HSprite;
	public var t(default, null) : Text;

	var shadow : h2d.filter.Glow;

	public var text(get, set) : String;
	inline function get_text() : String return t.text;
	inline function set_text(text : String) : String
	{
		t.text = text;
		if (bg == null)
		{
			width = t.textWidth;
			height = t.textHeight;
		}
		return text;
	}

	var fontStyle : EFontStyle;

	/**
	 * Set the textColor when the button is focused (will be toned down if `alterText` is `true`).
	 * Also changes the dropShadow color setting to `M.iabs(textColor - 0xFFFFFF)`.
	 */
	public var textColor(default, set) : Int;
	function set_textColor(c : Int)
	{
		if (t.dropShadow != null)
			t.dropShadow.color = M.iabs(c - 0xFFFFFF);
		if (alterText)
			t.textColor = M.iabs(c - 0x404040);
		else
			t.textColor = c;
		return textColor = c;
	}

	public var alterText(default, set) : Bool = false;
	function set_alterText(a : Bool)
	{
		if (alterText)
			t.textColor = M.iabs(textColor - 0x404040);
		return alterText = a;
	}

	public var dropShadow(get, set) : {dx : Float, dy : Float, color : Int, alpha : Float};
	function get_dropShadow()
	{
		return t.dropShadow;
	}
	function set_dropShadow(s)
	{
		return t.dropShadow = s;
	}

	public var id(default, set) : String;
	inline function set_id(v)
	{
		id = name = v;
		return id;
	}

	var pressed(default, set) : Bool = false;
	function set_pressed(v)
	{
		pressed = v;
		updateState();
		return pressed;
	}
	var focused(default, set) : Bool = false;
	function set_focused(v)
	{
		focused = v;
		updateState();
		return focused;
	}
	public var enabled(default, set) : Bool = true;
	function set_enabled(v)
	{
		enabled = v;
		updateState();
		cursor = v ? Button : Default;
		return enabled;
	}

	public function new(ca : ControllerAccess<GameAction>, ?bgLib : SpriteLib, ?bgName : String, ?fontStyle : EFontStyle = Regular, ?parent : h2d.Object)
	{
		super(0, 0, ca, parent);
		this.fontStyle = fontStyle;

		// filter = shadow = new h2d.filter.Glow(0, 0.4, 20, 1, 1, true);

		if (bgName != null)
		{
			bg = new HSprite(bgLib, '${bgName}_Idle', this);
			bg.name = bgName;
			bg.anim.setGlobalSpeed(8 / Const.FPS);
			bg.setPivotCoord(bg.tile.dx, bg.tile.dy);

			width = bg.tile.width;
			height = bg.tile.height;
		}

		t = new Text(Assets.font(fontStyle), this);
		if (bg != null)
		{
			t.textAlign = Center;
			t.maxWidth = bg.tile.width;
		}
		textColor = 0x000000;
		alterText = bg == null;

		updateState();
	}

	override function onAdd()
	{
		super.onAdd();
		Lang.langUpdateDelegates.push(updateText);
	}

	function updateText()
	{
		var newFont = Assets.font(fontStyle);
		if (newFont != null)
			t.font = newFont;
		if (id != null)
			text = Lang.t.get(id);
	}

	override function onRemove()
	{
		super.onRemove();
		Lang.langUpdateDelegates.remove(updateText);
	}

	override function getBoundsRec(relativeTo : Object, out : Bounds, forSize : Bool)
	{
		if (forSize)
		{
			if (posChanged)
			{
				calcAbsPos();
				for (c in children)
					c.posChanged = true;
				posChanged = false;
			}
			addBounds(relativeTo, out, 0, 0, Std.int(width), Std.int(height));
		} else
			super.getBoundsRec(relativeTo, out, forSize);
	}

	function updateState()
	{
		if (enabled)
		{
			if (focused)
			{
				if (pressed)
				{
					if (bg != null)
						bg.anim.playAndLoop('${bg.name}_Press');
					if (alterText)
						t.textColor = textColor;
				} else
				{
					if (bg != null)
						bg.anim.playAndLoop('${bg.name}_Hover');
					if (alterText)
						t.textColor = textColor;
				}
			} else
			{
				if (pressed)
				{
					if (bg != null)
						bg.anim.playAndLoop('${bg.name}_Hover');
					if (alterText)
						t.textColor = M.iabs(textColor - 0x404040);
				} else
				{
					if (bg != null)
						bg.anim.playAndLoop('${bg.name}_Idle');
					if (alterText)
						t.textColor = M.iabs(textColor - 0x404040);
				}
			}
		} else
		{
			if (bg != null)
				bg.anim.playAndLoop('${bg.name}_Disabled');
			if (alterText)
				t.textColor = 0x808080;
		}
	}

	override public function handleEvent(e : hxd.Event)
	{
		if (!enabled /* && checkBounds(e) */)
		{
			e.cancel = true;
			return;
		}
		super.handleEvent(e);
		if (!e.cancel)
			switch (e.kind)
			{
				case EOver:
					focus();
				case EFocus:
					focused = true;
				case EOut:
					blur();
				case EFocusLost:
					focused = false;
				case EPush:
					pressed = true;
				case ERelease, EReleaseOutside:
					pressed = false;
					focused = false;
				default:
			}
	}
}