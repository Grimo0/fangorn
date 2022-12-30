/**
	"App" class takes care of all the top-level stuff in the whole application. Any other Process, including Game instance, should be a child of App.
**/

import tools.script.Script;

class App extends dn.Process
{
	public static var ME : App;

	/** 2D scene **/
	public var s2d(default, null) : h2d.Scene;
	/** 3D scene **/
	public var s3d(default, null) : h3d.scene.Scene;

	/** Used to create "ControllerAccess" instances that will grant controller usage (keyboard or gamepad) **/
	public var controller : Controller<GameAction>;

	/** Controller Access created for App & Boot **/
	public var ca : ControllerAccess<GameAction>;

	/** 2d Root color matrix **/
	public var cmFilter : h2d.filter.ColorMatrix;

	/** If TRUE, game is paused, and a Contrast filter is applied **/
	public var screenshotMode(default, null) = false;

	public var pxWid(get, never) : Int;
	function get_pxWid() return M.ceil(s2d.width / Const.SCALE);
	public var pxHei(get, never) : Int;
	function get_pxHei() return M.ceil(s2d.height / Const.SCALE);

	public function new(s2d : h2d.Scene, s3d : h3d.scene.Scene)
	{
		super();
		ME = this;
		this.s2d = s2d;
		this.s3d = s3d;
		createRoot(s2d);

		hxd.Window.getInstance().addEventTarget(onWindowEvent);

		initEngine();
		initOptions();
		initAssets();
		initController();

		// Create console (open with [/] key)
		var console = new ui.Console(Assets.font(EFontStyle.Console)); // init debug console
		s2d.add(console, 9999);
		#if hlimgui
		trace('Press ² to toggle ImGui');
		#end

		// Optional screen that shows a "Click to start/continue" message when the game client looses focus
		if (dn.heaps.GameFocusHelper.isUseful())
			new dn.heaps.GameFocusHelper(s2d, Assets.font(EFontStyle.Regular));

		#if debug
		if (Options.ME.debug.stats)
			Console.ME.enableStats();
		#end

		startGame();
	}

	function onWindowEvent(ev : hxd.Event)
	{
		switch ev.kind
		{
			case EPush:
			case ERelease:
			case EMove:
			case EOver: onMouseEnter(ev);
			case EOut: onMouseLeave(ev);
			case EWheel:
			case EFocus: onWindowFocus(ev);
			case EFocusLost: onWindowBlur(ev);
			case EKeyDown:
			case EKeyUp:
			case EReleaseOutside:
			case ETextInput:
			case ECheck:
		}
	}

	function onMouseEnter(e : hxd.Event) {}
	function onMouseLeave(e : hxd.Event) {}
	function onWindowFocus(e : hxd.Event) {}
	function onWindowBlur(e : hxd.Event) {}

	#if hl
	public static function onCrash(err : Dynamic)
	{
		var title = L.untranslated("Fatal error");
		var msg = L.untranslated('I\'m really sorry but the game crashed! Error: ${Std.string(err)}');
		var flags : haxe.EnumFlags<hl.UI.DialogFlags> = new haxe.EnumFlags();
		flags.set(IsError);

		var log = [Std.string(err)];
		try
		{
			log.push("BUILD: " + Const.BUILD_INFO);
			log.push("EXCEPTION:");
			log.push(haxe.CallStack.toString(haxe.CallStack.exceptionStack()));

			log.push("CALL:");
			log.push(haxe.CallStack.toString(haxe.CallStack.callStack()));

			sys.io.File.saveContent("crash.log", log.join("\n"));
			hl.UI.dialog(title, msg, flags);
		}
		catch (_)
		{
			sys.io.File.saveContent("crash2.log", log.join("\n"));
			hl.UI.dialog(title, msg, flags);
		}

		hxd.System.exit();
	}
	#end

	/** Start game process **/
	public function startGame()
	{
		if (Game.exists())
		{
			// Kill previous game instance first
			Game.ME.destroy();
			dn.Process.updateAll(1); // ensure all garbage collection is done
			_createGameInstance();
			hxd.Timer.skip();
		}
		else
		{
			// Fresh start
			delayer.addF(() ->
			{
				_createGameInstance();
				hxd.Timer.skip();
			}, 1);
		}
	}

	final function _createGameInstance()
	{
		new Game();
	}

	public function anyInputHasFocus(ignoreModals = false)
	{
		return Console.ME.isActive() || cd.has("consoleRecentlyActive") || (!ignoreModals && ui.win.Modal.hasAny())
		#if hlimgui || ImGui.wantCaptureMouse() #end;
	}

	/**
		Set "screenshot" mode.
		If enabled, the game will be adapted to be more suitable for screenshots: more color contrast, no UI etc.
	**/
	public function setScreenshotMode(v : Bool)
	{
		screenshotMode = v;

		if (screenshotMode)
		{
			var f = new h2d.filter.ColorMatrix();
			f.matrix.colorContrast(0.2);
			root.filter = f;
			if (Game.exists())
			{
				Game.ME.hud.root.visible = false;
				#if debug
				Game.ME.debugHud.root.visible = false;
				#end
				Game.ME.pause();
			}
		}
		else
		{
			if (Game.exists())
			{
				Game.ME.hud.root.visible = true;
				#if debug
				Game.ME.debugHud.root.visible = true;
				#end
				Game.ME.resume();
			}
			root.filter = cmFilter;
		}
	}

	/** Toggle current game pause state **/
	public inline function toggleGamePause() setGamePause(!isGamePaused());

	/** Return TRUE if current game is paused **/
	public inline function isGamePaused() return Game.exists() && Game.ME.isPaused();

	/** Set current game pause state **/
	public function setGamePause(pauseState : Bool)
	{
		if (Game.exists())
			if (pauseState)
				Game.ME.pause();
			else
				Game.ME.resume();
	}

	/**
		Initialize low-level engine stuff, before anything else
	**/
	function initEngine()
	{
		// Engine settings
		engine.backgroundColor = 0xff << 24 | 0x111133;

		// Framerate
		hxd.Timer.smoothFactor = 0.4;

		#if (hl && !debug)
		hl.UI.closeConsole();
		hl.Api.setErrorHandler(onCrash);
		#end

		// Creating the ColorMatrix filter
		root.filter = cmFilter = new h2d.filter.ColorMatrix();

		new SoundManager();

		Script.init();
	}

	/**
		Init user options
	**/
	function initOptions()
	{
		new Options();
		Options.ME.load();
	}

	/**
		Init app assets
	**/
	function initAssets()
	{
		// Heaps resource management
		#if (hl && debug)
		hxd.Res.initLocal();
		hxd.res.Resource.LIVE_UPDATE = Options.ME.debug.hotReload;
		#else
		hxd.Res.initEmbed();
		#end

		// Init game assets
		Assets.init();

		// Init lang data
		Lang.load(Options.ME.language);

		// Bind DB hot-reloading callback
		Const.db.onReload = onDbReload;
	}

	/** Init game controller and default key bindings **/
	function initController()
	{
		controller = dn.heaps.input.Controller.createFromAbstractEnum(GameAction);
		ca = controller.createAccess();
		ca.lockCondition = () -> return destroyed || anyInputHasFocus();

		initControllerBindings();
	}

	public function initControllerBindings()
	{
		controller.removeBindings();

		// Gamepad bindings
		controller.bindPadLStick4(MoveLeft, MoveRight, MoveUp, MoveDown);
		controller.bindPad(Jump, A);
		controller.bindPad(Restart, SELECT);
		controller.bindPad(Pause, START);
		controller.bindPad(MoveUp, [DPAD_UP, LSTICK_UP]);
		controller.bindPad(MoveDown, [DPAD_DOWN, LSTICK_DOWN]);
		controller.bindPad(MoveLeft, [DPAD_LEFT, LSTICK_LEFT]);
		controller.bindPad(MoveRight, [DPAD_RIGHT, LSTICK_RIGHT]);

		controller.bindPad(MenuUp, [DPAD_UP, LSTICK_UP]);
		controller.bindPad(MenuDown, [DPAD_DOWN, LSTICK_DOWN]);
		controller.bindPad(MenuLeft, [DPAD_LEFT, LSTICK_LEFT]);
		controller.bindPad(MenuRight, [DPAD_RIGHT, LSTICK_RIGHT]);
		controller.bindPad(MenuOk, [A, X]);
		controller.bindPad(MenuCancel, B);

		// Keyboard bindings
		controller.bindKeyboard(MoveUp, [K.UP, K.Z]);
		controller.bindKeyboard(MoveDown, [K.DOWN, K.S]);
		controller.bindKeyboard(MoveLeft, [K.LEFT, K.Q]);
		controller.bindKeyboard(MoveRight, [K.RIGHT, K.D]);
		controller.bindKeyboard(Jump, K.SPACE);
		controller.bindKeyboard(Restart, K.R);
		controller.bindKeyboard(ScreenshotMode, K.F9);
		controller.bindKeyboard(Pause, K.P);
		controller.bindKeyboard(Pause, K.PAUSE_BREAK);

		controller.bindKeyboard(MenuUp, [K.UP, K.Z]);
		controller.bindKeyboard(MenuDown, [K.DOWN, K.S]);
		controller.bindKeyboard(MenuLeft, [K.LEFT, K.Q]);
		controller.bindKeyboard(MenuRight, [K.RIGHT, K.D]);
		controller.bindKeyboard(MenuOk, [K.SPACE, K.ENTER, K.F]);
		controller.bindKeyboard(MenuCancel, K.ESCAPE);
		controller.bindKeyboardCombo(Fullscreen, [K.ALT, K.ENTER]);

		// Debug controls
		#if debug
		controller.bindPad(DebugTurbo, LT);
		controller.bindPad(DebugSlowMo, LB);
		controller.bindPad(DebugDroneZoomIn, RSTICK_UP);
		controller.bindPad(DebugDroneZoomOut, RSTICK_DOWN);

		controller.bindKeyboard(DebugDroneZoomIn, K.PGUP);
		controller.bindKeyboard(DebugDroneZoomOut, K.PGDOWN);
		controller.bindKeyboard(DebugTurbo, [K.END, K.NUMPAD_ADD]);
		controller.bindKeyboard(DebugSlowMo, [K.HOME, K.NUMPAD_SUB]);
		controller.bindPadCombo(ToggleDebugDrone, [LSTICK_PUSH, RSTICK_PUSH]);
		controller.bindKeyboardCombo(ToggleDebugDrone, [K.D, K.CTRL, K.SHIFT]);
		#end
	}

	/** Return TRUE if an App instance exists **/
	public static inline function exists() return ME != null && !ME.destroyed;

	/** Close & exit the app **/
	public function exit()
	{
		destroy();
	}

	override function onDispose()
	{
		super.onDispose();

		ca.dispose();

		hxd.Window.getInstance().removeEventTarget(onWindowEvent);

		#if hl
		hxd.System.exit();
		#end
	}

	/** Called when Const.db values are hot-reloaded **/
	public function onDbReload()
	{
		if (Game.exists())
			Game.ME.onDbReload();
	}

	override function update()
	{
		Assets.update(tmod);

		super.update();

		if (ca.isPressed(ScreenshotMode))
			setScreenshotMode(!screenshotMode);

		if (ca.isPressed(Pause))
			toggleGamePause();

		if (isGamePaused() && ca.isPressed(MenuCancel))
			setGamePause(false);

		if (ui.Console.ME.isActive())
			cd.setF("consoleRecentlyActive", 2);

		if (ca.isPressed(Fullscreen))
			Options.ME.fullscreen = !Options.ME.fullscreen;

		// Mem track reporting
		#if debug
		if (ca.isKeyboardDown(K.SHIFT) && ca.isKeyboardPressed(K.ENTER))
		{
			Console.ME.runCommand("/cls");
			dn.debug.MemTrack.report((v) -> Console.ME.log(v, Yellow));
		}
		#end
	}
}