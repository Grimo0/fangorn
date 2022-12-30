/**
 * Based on Deepnight code from his LD43 game and LD47 game.
 * https://github.com/deepnight/ld43-saveAndSacrifices/blob/master/src/GameCinematic.hx
 * https://github.com/deepnight/ld47-fortLoop/blob/master/src/Intro.hx
 */
class GameCinematic extends GameChildProcess
{
	public static var ALL : Array<GameCinematic> = [];
	public static function hasAny() return ALL.length > 0;

	public var cid(default, null) : String;

	var cm = new dn.Cinematic(Const.FPS);

	function new(cid : String)
	{
		super();
		ALL.push(this);
		createRootInLayers(game.root, Const.DP_TOP);

		this.cid = cid;

		cm = new dn.Cinematic(Const.FPS);
	}

	override function onDispose()
	{
		super.onDispose();
		cm.destroy();
		cm = null;
		ALL.remove(this);
	}

	override function preUpdate()
	{
		super.preUpdate();
		cm.update(tmod);
	}
}