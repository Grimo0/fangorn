package s2d;

import hxd.Event;

// TODO Allow for a shape in selection (h2d.col.Collider)
class Draggable extends Interactive
{
	public var pushX(default, null) : Float;
	public var pushY(default, null) : Float;
	public var oldX(default, null) : Float;
	public var oldY(default, null) : Float;
	public var touchId(default, null) : Null<Int>;

	override function set_isLocked(b : Bool) : Bool
	{
		@:privateAccess
		if (b && touchId != null && scene.events.currentDrag != null && scene.events.currentDrag.ref == touchId)
		{
			App.ME.delayer.addF(() -> scene.stopCapture(), 1);
		}
		return super.set_isLocked(b);
	}

	public function new(w : Float, h : Float, ca : ControllerAccess<GameAction>, ?parent : h2d.Object)
	{
		super(w, h, ca, parent);
	}

	override function onPush(e : hxd.Event)
	{
		if (e.cancel) return;
		oldX = x;
		oldY = y;

		// Convert from local to global
		pushX = e.relX * matA + e.relY * matC + absX;
		pushY = e.relX * matB + e.relY * matD + absY;

		onDragStart();

		scene.startCapture(
			(e : hxd.Event) ->
			{
				switch (e.kind)
				{
					case ERelease, EReleaseOutside, EKeyDown:
						if (scene != null)
							scene.stopCapture();
					case EMove, ECheck:
						onDrag(e);
					case _: null;
				}
			}, () ->
			{
				onDrop();
				touchId = null;
			}, touchId = e.touchId);
	}

	public dynamic function onDragStart()
	{
		dragStart();
	}
	public function dragStart() {}

	public dynamic function onDrag(e : hxd.Event)
	{
		drag(e);
	}
	public function drag(e : hxd.Event)
	{
		x = oldX + e.relX - pushX;
		y = oldY + e.relY - pushY;
	}

	public dynamic function onDrop()
	{
		drop();
	}
	public function drop() {}
}