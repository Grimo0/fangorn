/**	This abstract enum is used by the Controller class to bind general game actions to actual keyboard keys or gamepad buttons. **/
enum abstract GameAction(Int) to Int
{
	var MoveUp;
	var MoveDown;
	var MoveLeft;
	var MoveRight;
	var Jump;
	var Restart;
	var MenuUp;
	var MenuDown;
	var MenuLeft;
	var MenuRight;
	var MenuOk;
	var MenuCancel;
	var Pause;
	var ToggleDebugDrone;
	var DebugDroneZoomIn;
	var DebugDroneZoomOut;
	var DebugTurbo;
	var DebugSlowMo;
	var ScreenshotMode;
	var Fullscreen;
}

/** Entity state machine. Each entity can only have 1 active State at a time. **/
enum abstract State(Int)
{
	var Normal;
}

/** Entity Affects have a limited duration in time and you can stack different affects. **/
enum abstract Affect(Int)
{
	var Stun;
}

enum abstract LevelMark(Int) to Int
{
	var M_Coll_Wall; // 0
}

enum abstract LevelSubMark(Int) to Int
{
	var SM_None; // 0
}

enum abstract SlowMoId(Int) to Int
{
	var S_Default; // 0
}

enum abstract ChargedAction(Int) to Int {}