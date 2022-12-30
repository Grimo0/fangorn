package ui;

import s2d.Interactive;
import hxd.Event;
import h2d.RenderContext;
import h2d.Text;

class SliderInteractive extends Interactive
{
	override function handleEvent(e : Event)
	{
		super.handleEvent(e);
		if (e.kind == EOver)
		{
			focus();
		} else if (e.kind != EMove && e.kind != ECheck && e.kind != EFocus && e.kind != EFocusLost)
			e.cancel = true;
		e.propagate = true;
	}
}

class Slider extends Interactive
{
	public var backgroundTile : h2d.Tile;
	public var progressTile : h2d.Tile;
	public var cursorTile : h2d.Tile;

	public var minValue(default, set) : Float = 0.;
	function set_minValue(v)
	{
		if (value < v) value = v;
		return minValue = v;
	}

	public var maxValue(default, set) : Float = 1.;
	function set_maxValue(v)
	{
		if (value > v) value = v;
		return maxValue = v;
	}

	public var value(default, set) : Float = 0.;
	function set_value(v)
	{
		if (v < minValue) v = minValue;
		if (v > maxValue) v = maxValue;
		@:privateAccess {
			progressTile.width = width * (v - minValue) / (maxValue - minValue);
			progressTile.u2 = (progressTile.x + progressTile.width) / progressTile.innerTex.width;
		}
		return value = v;
	}

	public function new(?wid : Int, ?hei : Int, ca : ControllerAccess<GameAction>, ?parent)
	{
		if (wid == null)
			wid = 50;
		if (hei == null)
			hei = 10;
		super(wid, hei, ca, parent);

		// TODO backgroundTile = Assets.ui.getTile('Slider);
		backgroundTile = h2d.Tile.fromColor(0x404040, wid, hei);
		// backgroundTile.scaleToSize(wid, hei);
		backgroundTile.dy = (hei - Std.int(backgroundTile.height)) >> 1;

		// TODO progressTile = Assets.ui.getTile('Slider_Progress);
		progressTile = h2d.Tile.fromColor(0x808080, wid, hei);
		// progressTile.scaleToSize(wid, hei);
		progressTile.dy = (hei - Std.int(progressTile.height)) >> 1;

		// TODO cursorTile = Assets.ui.getTile('Slider_Cursor);
		cursorTile = h2d.Tile.fromColor(0xFFFFFF, 5, hei);
	}

	override function getBoundsRec(relativeTo, out, forSize)
	{
		super.getBoundsRec(relativeTo, out, forSize);
		if (forSize) addBounds(relativeTo, out, 0, 0, width, height);
		if (backgroundTile != null)
			addBounds(relativeTo, out, backgroundTile.dx, backgroundTile.dy, backgroundTile.width, backgroundTile.height);
		if (progressTile != null)
			addBounds(relativeTo, out, progressTile.dx, progressTile.dy, progressTile.width, progressTile.height);
		if (cursorTile != null)
			addBounds(relativeTo, out, cursorTile.dx + getDx(), cursorTile.dy, cursorTile.width, cursorTile.height);
	}

	override function draw(ctx : RenderContext)
	{
		super.draw(ctx);
		if (backgroundTile.width != Std.int(width))
		{
			backgroundTile.scaleToSize(Std.int(width), backgroundTile.height);
			backgroundTile.dy = Std.int(height - backgroundTile.height) >> 1;
			progressTile.scaleToSize(Std.int(width), progressTile.height);
			progressTile.dy = Std.int(height - progressTile.height) >> 1;
		}
		emitTile(ctx, backgroundTile);
		emitTile(ctx, progressTile);
		var px = getDx();
		cursorTile.dx += px;
		emitTile(ctx, cursorTile);
		cursorTile.dx -= px;
	}

	var handleDX = 0.0;
	inline function getDx()
	{
		return Math.round((value - minValue) * (width - cursorTile.width) / (maxValue - minValue));
	}

	inline function getValue(cursorX : Float) : Float
	{
		return ((cursorX - handleDX) / (width - cursorTile.width)) * (maxValue - minValue) + minValue;
	}

	override function handleEvent(e : hxd.Event)
	{
		super.handleEvent(e);
		if (e.cancel) return;
		switch (e.kind)
		{
			case EPush:
				var dx = getDx();
				handleDX = e.relX - dx;

				// If clicking the slider outside the handle, drag the handle
				// by the center of it.
				if (handleDX - cursorTile.dx < 0 || handleDX - cursorTile.dx > cursorTile.width)
				{
					handleDX = cursorTile.width * 0.5;
				}

				value = getValue(e.relX);

				onChange();
				var scene = scene;
				startCapture(function(e)
				{
					if (this.scene != scene || e.kind == ERelease)
					{
						scene.stopCapture();
						return;
					}
					value = getValue(e.relX);
					onChange();
				}, onCancel);
			default:
		}
	}

	/**
		Called when slider value is changed by user.

		Not called if value is set manually from software side.
	**/
	public dynamic function onChange() {}

	/**
		Called when the slider is released.
	**/
	public dynamic function onCancel() {}
}

class OptionSlider extends h2d.Object
{
	var interactive : SliderInteractive;
	var t : Text;

	public var textWidth(default, set) : Null<Float>;
	function set_textWidth(w : Null<Float>) : Null<Float>
	{
		if (w == null)
		{
			slider.x = 0;
		} else
		{
			slider.x = w + 20;
		}
		interactive.width = slider.x + slider.width;
		t.maxWidth = w;
		return textWidth = w;
	}

	public var fontStyle(default, set) : EFontStyle;
	function set_fontStyle(f : EFontStyle) : EFontStyle
	{
		t.font = Assets.font(fontStyle = f);
		@:privateAccess slider.y = (t.font.lineHeight - slider.height) / 2;
		if (textWidth == null)
		{
			slider.x = textWidth + 20;
			interactive.width = slider.x + slider.width;
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
			slider.x = t.textWidth + 20;
			interactive.width = slider.x + slider.width;
		}
		return t.text;
	}

	public var id(default, set) : String;
	inline function set_id(v)
	{
		id = name = v;
		return id;
	}

	var slider : Slider;

	public var minValue(get, set) : Float;
	inline function get_minValue() return slider.minValue;
	inline function set_minValue(v) return slider.minValue = v;

	public var maxValue(get, set) : Float;
	inline function get_maxValue() return slider.maxValue;
	inline function set_maxValue(v) return slider.maxValue = v;

	public var value(get, set) : Float;
	inline function get_value() return slider.value;
	inline function set_value(v) return slider.value = v;

	public var onChange(never, set) : Void->Void;
	inline function set_onChange(onChange : Void->Void) : Void->Void return slider.onChange = onChange;
	public var onCancel(never, set) : Void->Void;
	inline function set_onCancel(onCancel : Void->Void) : Void->Void return slider.onCancel = onCancel;

	public var width(get, set) : Float;
	inline function get_width() : Float return slider.width;
	inline function set_width(width : Float) : Float
	{
		slider.width = width;
		interactive.width = slider.x + slider.width;
		return width;
	}

	public var height(get, set) : Float;
	inline function get_height() : Float return slider.height;
	inline function set_height(height : Float) : Float
	{
		slider.height = height;
		interactive.height = t.font.lineHeight * 3 / 4;
		interactive.y = (t.font.lineHeight - interactive.height) / 3;
		return height;
	}

	public function new(wid : Int, ?hei : Int, fontStyle : EFontStyle = Regular, ca : ControllerAccess<GameAction>, ?p : h2d.Object)
	{
		super(p);

		t = new Text(Assets.font(fontStyle), this);
		t.textColor = 0;

		slider = new Slider(wid, hei != null ? hei : Std.int(t.font.lineHeight) >> 1, ca, this);
		@:privateAccess slider.y = (t.font.lineHeight - slider.height) / 2;

		interactive = new SliderInteractive(0, 0, ca, this);
		interactive.cursor = null;
		interactive.width = slider.x + slider.width;
		interactive.height = t.font.lineHeight * 3 / 4;
		interactive.y = (t.font.lineHeight - interactive.height) / 3;

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
}