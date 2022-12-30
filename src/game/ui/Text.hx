package ui;

import h2d.Object;
import h2d.col.Bounds;

class Text extends h2d.Text
{
	override function getBoundsRec(relativeTo : Object, out : Bounds, forSize : Bool)
	{
		super.getBoundsRec(relativeTo, out, forSize);
		updateSize();
		addBounds(relativeTo, out, calcXMin, calcYMin, calcWidth, calcHeight - calcYMin);
	}
}