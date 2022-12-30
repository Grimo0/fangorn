package ui;

class DebugHud extends GameChildProcess
{
	var flow : h2d.Flow;

	public function new()
	{
		super();

		createRootInLayers(game.root, Const.DP_DEBUG);
		root.filter = new h2d.filter.Nothing(); // force pixel perfect rendering

		flow = new h2d.Flow(root);
		flow.layout = Vertical;
		flow.verticalSpacing = 5;
		flow.padding = 10;
	}

	function getFont()
	{
		return hxd.res.DefaultFont.get();
	}

	public function addButton(label : String, onClick : Void->Void)
	{
		var f = new h2d.Flow(flow);
		f.padding = 5;
		f.paddingBottom = 7;
		f.backgroundTile = h2d.Tile.fromColor(0x404040);
		var tf = new h2d.Text(getFont(), f);
		tf.text = label;
		f.enableInteractive = true;
		f.interactive.cursor = Button;
		f.interactive.onClick = function(_) onClick();
		f.interactive.onOver = function(_) f.backgroundTile = h2d.Tile.fromColor(0x606060);
		f.interactive.onOut = function(_) f.backgroundTile = h2d.Tile.fromColor(0x404040);
		return f;
	}

	public function addSlider(label : String, get : Void->Float, set : Float->Void, min : Float = 0., max : Float = 1.)
	{
		var f = new h2d.Flow(flow);

		f.horizontalSpacing = 5;

		var tf = new h2d.Text(getFont(), f);
		tf.text = label;
		tf.maxWidth = 70;
		tf.textAlign = Right;

		var defaultV = get();
		var reset = new h2d.Interactive(tf.maxWidth, tf.font.lineHeight, tf);

		var sli = new h2d.Slider(100, Std.int(tf.font.lineHeight), f);
		sli.minValue = min;
		sli.maxValue = max;
		sli.value = get();

		var ti = new h2d.TextInput(getFont(), f);
		ti.text = "" + hxd.Math.fmt(sli.value);

		reset.onClick = (e) ->
		{
			sli.value = defaultV;
			set(defaultV);
			ti.text = "" + hxd.Math.fmt(sli.value);
			f.needReflow = true;
		};
		sli.onChange = function()
		{
			set(sli.value);
			ti.text = "" + hxd.Math.fmt(sli.value);
			f.needReflow = true;
		};
		ti.onChange = function()
		{
			var v = Std.parseFloat(ti.text);
			if (Math.isNaN(v)) return;
			sli.value = v;
			set(v);
		};
		return sli;
	}

	public function addCheck(label : String, get : Void->Bool, set : Bool->Void)
	{
		var f = new h2d.Flow(flow);

		f.horizontalSpacing = 5;

		var tf = new h2d.Text(getFont(), f);
		tf.text = label;
		tf.maxWidth = 70;
		tf.textAlign = Right;

		var size = 10;
		var b = new h2d.Graphics(f);
		function redraw()
		{
			b.clear();
			b.beginFill(0x808080);
			b.drawRect(0, 0, size, size);
			b.beginFill(0);
			b.drawRect(1, 1, size - 2, size - 2);
			if (get())
			{
				b.beginFill(0xC0C0C0);
				b.drawRect(2, 2, size - 4, size - 4);
			}
		}
		var i = new h2d.Interactive(size, size, b);
		i.onClick = function(_)
		{
			set(!get());
			redraw();
		};
		redraw();
		return i;
	}

	public function addChoice(text, choices, callb : Int->Void, value = 0)
	{
		var font = getFont();
		var i = new h2d.Interactive(110, font.lineHeight, flow);
		i.backgroundColor = 0xFF808080;
		flow.getProperties(i).paddingLeft = 20;

		var t = new h2d.Text(font, i);
		t.maxWidth = i.width;
		t.text = text + ":" + choices[value];
		t.textAlign = Center;

		i.onClick = function(_)
		{
			value++;
			value %= choices.length;
			callb(value);
			t.text = text + ":" + choices[value];
		};
		i.onOver = function(_)
		{
			t.textColor = 0xFFFFFF;
		};
		i.onOut = function(_)
		{
			t.textColor = 0xEEEEEE;
		};
		i.onOut(null);
		return i;
	}

	public function addText(text = "")
	{
		var tf = new h2d.Text(getFont(), flow);
		tf.text = text;
		return tf;
	}
}