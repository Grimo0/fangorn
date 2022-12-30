package tools;

class AppChildProcess extends dn.Process
{
	public static var ALL : FixedArray<AppChildProcess> = new FixedArray(32);

	public var app(get, never) : App;
	inline function get_app() return App.ME;

	public var pxWid(get, never) : Int;
	function get_pxWid() return app.pxWid;
	public var pxHei(get, never) : Int;
	function get_pxHei() return app.pxHei;

	public function new()
	{
		super(App.ME);
		ALL.push(this);
	}

	override function onDispose()
	{
		super.onDispose();
		ALL.remove(this);
	}

	override function update()
	{
		super.update();

		#if hlimgui
		this.imguiDefaultDisplay(updateImGui, pxWid, pxHei);
		#end
	}

	#if hlimgui
	function updateImGui() {}
	#end
}