package s2d;

import h2d.Mask;
import h2d.RenderContext;
import h2d.Object;

class ClipBox extends Object
{
	public var width : Int;
	public var height : Int;

	public function new(?parent : Object, ?w : Int, ?h : Int)
	{
		super(parent);
		width = w;
		height = h;
	}

	override function drawRec(ctx : RenderContext)
	{
		Mask.maskWith(ctx, this, width, height);
		super.drawRec(ctx);
		Mask.unmask(ctx);
	}
}