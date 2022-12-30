package ui;

class Console extends h2d.Console
{
	public static var ME : Console;

	#if debug
	var flags : Map<String, Bool>;
	#end

	var stats : Null<dn.heaps.StatsBox>;

	public function new(f : h2d.Font, ?p : h2d.Object)
	{
		super(f, p);

		logTxt.filter = new dn.heaps.filter.PixelOutline();
		scale(2); // TODO smarter scaling for 4k screens
		logTxt.condenseWhite = false;
		errorColor = 0xff6666;

		// Settings
		ME = this;
		h2d.Console.HIDE_LOG_TIMEOUT = #if debug 10 #else 5 #end;
		Lib.redirectTracesToH2dConsole(this);

		#if debug
		// Debug flags (/set, /unset, /list commands)
		flags = new Map();
		this.addCommand("set", 'Set the flag "k"', [{name: "k", t: AString}], function(k : String)
		{
			setFlag(k, true);
			log("+ " + k.toLowerCase(), 0x80FF00);
		});
		this.addCommand("unset", 'Unset the flag "k"', [{name: "k", t: AString, opt: true}], function(?k : String)
		{
			if (k == null)
			{
				log("Reset all.", 0xFF0000);
				for (k in flags.keys())
					setFlag(k, false);
			}
			else
			{
				log("- " + k, 0xFF8000);
				setFlag(k, false);
			}
		});
		this.addCommand("list", "List the flags", [], function()
		{
			for (k in flags.keys())
				log(k, 0x80ff00);
		});
		this.addAlias("+", "set");
		this.addAlias("-", "unset");

		// Controller debugger
		this.addCommand("ctrl", "Controller debugger", [], () ->
		{
			App.ME.ca.toggleDebugger(App.ME, dbg ->
			{
				dbg.root.filter = new dn.heaps.filter.PixelOutline();
			});
		});

		// Garbage collector
		this.addCommand("gc", "Try to run the garbage collector", [{name: "state", t: AInt, opt: true}], (?state : Int) ->
		{
			if (!dn.Gc.isSupported())
				log("GC is not supported on this platform", Red);
			else
			{
				if (state != null)
					dn.Gc.setState(state != 0);
				dn.Gc.runNow();
				log("GC forced (current state: " + (dn.Gc.isActive() ? "active" : "inactive") + ")", dn.Gc.isActive() ? Green : Yellow);
			}
		});

		// Level marks
		var allLevelMarks : Array<{name : String, value : Int}>;
		allLevelMarks = dn.MacroTools.getAbstractEnumValues(Types.LevelMark);
		this.addCommand(
			"mark",
			"Level marks",
			[
				{name: "levelMark", t: AEnum(allLevelMarks.map(m -> m.name)), opt: true},
				{name: "bit", t: AInt, opt: true},
			],
			(k : String, bit : Null<Int>) ->
			{
				if (!Game.exists())
				{
					error('Game is not running');
					return;
				}
				if (k == null)
				{
					// Game.ME.level.clearDebug();
					return;
				}

				var bit : Null<LevelSubMark> = cast bit;
				var mark = -1;
				for (m in allLevelMarks)
					if (m.name == k)
					{
						mark = m.value;
						break;
					}
				if (mark < 0)
				{
					error('Unknown level mark $k');
					return;
				}

				var col = 0xffcc00;
				log('Displaying $mark (bit=$bit)...', col);
				// Game.ME.level.renderDebugMark(cast mark, bit);
			}
		);
		this.addAlias("m", "mark");
		#end

		// List all active dn.Process
		this.addCommand("process", "List all active dn.Process", [], () ->
		{
			for (l in App.ME.rprintChildren().split("\n"))
				log(l);
		});
		this.addAlias("p", "process");

		// Show build info
		this.addCommand("build", "Show build info", [], () -> log(Const.BUILD_INFO));

		// Create a debug drone
		#if debug
		this.addCommand("drone", "Create a debug drone", [], () ->
		{
			new en.DebugDrone();
		});
		#end

		// Create a stats box
		this.addCommand("fps", "Create a stats box", [], () -> toggleStats());
		this.addAlias("stats", "fps");

		// Options
		this.addCommand("options", "Log the options", [], () -> log(Options.ME.rprint()));
		this.addCommand("optionsSet", "Set an option value (0 or 1 for Bool)", [{name: "name", t: AString, opt: false}, {name: "value", t: AFloat, opt: false}], (name : String, value : Float) ->
		{
			var o : Dynamic = Options.ME;
			var fieldPath = name.split('.');
			var f = fieldPath[0];
			for (i in 1...fieldPath.length)
			{
				if (!Reflect.hasField(o, f))
				{
					log('No option named $fieldPath', errorColor);
					return;
				}

				o = Reflect.getProperty(o, f);
				f = fieldPath[i];
			}

			if (!Reflect.hasField(o, f))
			{
				log('No option named $fieldPath', errorColor);
				return;
			}

			Reflect.setProperty(o, f, value);
		});
		this.addAlias("oset", "optionsSet");
		this.addCommand("optionsSave", "Save the options", [], () ->
		{
			Options.ME.save();
			log('Options saved!');
		});
		this.addAlias("osave", "optionsSave");
		this.addCommand("optionsLoad", "Load the options", [], () ->
		{
			Options.ME.load();
			log('Options loaded!');
		});
		this.addAlias("oload", "optionsLoad");
		this.addCommand("optionsReset", "Reset the options to the default", [], () ->
		{
			Options.ME.reset();
			log('Options reset!');
		});
		this.addCommand("fullscreen", "Toggle the fullscreen", [], () -> Options.ME.fullscreen = !Options.ME.fullscreen);

		// Misc flag aliases
		addFlagCommandAlias("bounds");
		addFlagCommandAlias("affect");
		addFlagCommandAlias("scroll");
		addFlagCommandAlias("cam");
	}

	public function disableStats()
	{
		if (stats != null)
		{
			stats.destroy();
			stats = null;
		}
		Options.ME.debug.stats = false;
	}

	public function enableStats()
	{
		if (stats != null)
		{
			stats.destroy();
		}
		stats = new dn.heaps.StatsBox(App.ME);
		stats.addFpsChart();
		stats.addDrawCallsChart();
		#if hl
		stats.addMemoryChart();
		#end
		Options.ME.debug.stats = true;
	}

	public function toggleStats()
	{
		if (stats != null)
			disableStats();
		else
			enableStats();
	}

	override function getCommandSuggestion(cmd : String) : String
	{
		var sugg = super.getCommandSuggestion(cmd);
		if (sugg.length > 0)
			return sugg;

		if (cmd.length == 0)
			return "";

		// Simplistic argument auto-complete
		for (c in commands.keys())
		{
			var reg = new EReg("([ \t\\/]*" + c + "[ \t]+)(.*)", "gi");
			if (reg.match(cmd))
			{
				var lowArg = reg.matched(2).toLowerCase();
				for (a in commands.get(c).args)
					switch a.t
					{
						case AInt:
						case AFloat:
						case AString:
						case ABool:
						case AEnum(values):
							for (v in values)
								if (v.toLowerCase().indexOf(lowArg) == 0)
									return reg.matched(1) + v;
						case AArray(t):
					}
			}
		}

		return "";
	}

	/** Creates a shortcut command "/flag" to toggle specified flag state **/
	inline function addFlagCommandAlias(flag : String)
	{
		#if debug
		addCommand(flag, "Toggle this flag", [], () ->
		{
			setFlag(flag, !hasFlag(flag));
		});
		#end
	}

	override function handleCommand(command : String)
	{
		var flagReg = ~/[\/ \t]*\+[ \t]*([\w]+)/g; // cleanup missing spaces
		super.handleCommand(flagReg.replace(command, "/+ $1"));
	}

	public function error(msg : Dynamic)
	{
		log("[ERROR] " + Std.string(msg), errorColor);
		h2d.Console.HIDE_LOG_TIMEOUT = Const.INFINITE;
	}

	#if debug
	public function setFlag(k : String, v)
	{
		k = k.toLowerCase();
		var hadBefore = hasFlag(k);

		if (v)
			flags.set(k, v);
		else
			flags.remove(k);

		if (v && !hadBefore || !v && hadBefore)
			onFlagChange(k, v);
		return v;
	}
	public function hasFlag(k : String) return flags.get(k.toLowerCase()) == true;
	#else
	public function hasFlag(k : String) return false;
	#end

	public function onFlagChange(k : String, v : Bool) {}

	public inline function clearAndLog(str : Dynamic)
	{
		runCommand("cls");
		log(Std.string(str));
	}
}