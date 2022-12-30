package ui;

import h2d.col.Bounds;
import h2d.Object;

class HtmlText extends h2d.HtmlText
{
	public var id(default, set) : String;
	function set_id(v)
	{
		id = name = v;
		return id;
	}

	override function getBoundsRec(relativeTo : Object, out : Bounds, forSize : Bool)
	{
		super.getBoundsRec(relativeTo, out, forSize);
		addBounds(relativeTo, out, 0, 0, maxWidth, 1);
	}

	override function onAdd()
	{
		super.onAdd();
		Assets.fontUpdateDelegates.push(updateText);
		Lang.langUpdateDelegates.push(updateText);
	}

	function updateText()
	{
		font = Assets.fonts.get(font.name);
		if (id != null)
			text = Lang.t.get(id);
	}

	override function onRemove()
	{
		super.onRemove();
		Assets.fontUpdateDelegates.remove(updateText);
		Lang.langUpdateDelegates.remove(updateText);
	}
}