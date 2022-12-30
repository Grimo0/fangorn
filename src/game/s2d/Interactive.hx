package s2d;

class Interactive extends h2d.Interactive
{
	public var ca : ControllerAccess<GameAction>;

	public var isLocked(default, set) = false;
	function set_isLocked(b)
	{
		cancelEvents = b;
		propagateEvents = b;
		isLocked = b;
		return isLocked;
	}

	public function new(width, height, ca : ControllerAccess<GameAction>, ?parent, ?shape)
	{
		super(width, height, parent, shape);
		this.ca = ca;
	}

	override public function handleEvent(e : hxd.Event)
	{
		if (e.cancel)
		{
			return;
		}

		#if hlimgui
		if (ImGui.wantCaptureMouse())
		{
			e.cancel = true;
			return;
		}
		#end
		if (!ca.isActive() && e.kind != EFocus && e.kind != EFocusLost)
		{
			e.cancel = true;
			return;
		}
		e.cancel = false;
		super.handleEvent(e);
	}

	#if hlimgui
	function updateImGui() {}
	#end
}