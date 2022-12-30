package tools.script;

class Script
{
	public static var log : dn.Log;
	public static var parser : hscript.Parser;
	public static var interp : hscript.Interp;
	public static var checker : hscript.Checker;

	static function runLog(v : Dynamic)
	{
		log.add("run", Std.string(v));
	}

	/**
		Check if the provided hscript is valid.
		USAGE:
			Script.check('var a=1 ; a++ ; log(a) ; return a');
	**/
	public static function check(script : String) : Bool
	{
		// Init script
		init();
		log.clear();

		// Execute
		try
		{
			var program = parser.parseString(script);

			try checker.check(program)
			catch (e)
			{
				log.error(Std.string(e));
			}
		}
		catch (e)
		{
			log.error(Std.string(e));
		}

		if (log.containsAnyCriticalEntry())
		{
			// Error
			printLastLog();
			return false;
		}
		else
		{
			// Done!
			return true;
		}
	}

	/**
		Execute provided hscript.
		USAGE:
			Script.run('var a=1 ; a++ ; log(a) ; return a');
	**/
	public static function run(script : String)
	{
		// Init script
		init();
		log.clear();
		log.add("exec", "Script started.");

		// Execute
		var program = parser.parseString(script);
		var out : Dynamic = try interp.execute(program)
		catch (e:hscript.Expr.Error)
		{
			log.error(Std.string(e));
			null;
		}

		// Returned value
		if (out != null)
			log.add("exec", "Returned: " + out);

		if (log.containsAnyCriticalEntry())
		{
			// Error
			printLastLog();
			return false;
		}
		else
		{
			// Done!
			log.add("exec", "Script completed.");
			return true;
		}
	}

	/**
		Print last script log to default output
	**/
	public static function printLastLog()
	{
		log.printAll();
	}

	static var initDone = false;
	public static function init()
	{
		if (initDone)
			return;
		initDone = true;

		parser = new hscript.Parser();

		log = new dn.Log();
		log.outputConsole = Console.ME;
		log.tagColors.set("error", "#ff6c6c");
		log.tagColors.set("exec", "#a1b2db");
		log.tagColors.set("run", "#3affe5");

		// API
		interp = new hscript.Interp();
		var api = new tools.script.Api();
		interp.variables.set("api", api);
		interp.variables.set("log", runLog);

		checker = new hscript.Checker();
		@:privateAccess
		{
			var apiClassDef = haxe.rtti.Rtti.getRtti(Type.getClass(api));
			var todo = [];
			checker.types.addXmlType(TClassdecl(apiClassDef), todo);
			for (f in todo)
				f();
			checker.types.t_string = checker.types.getType("String");

			var apiType = checker.types.getType('tools.script.Api');
			checker.setGlobal('api', apiType);

			var t = hscript.Checker.TType.TFun([{name: 'v', opt: false, t: hscript.Checker.TType.TDynamic}], TVoid);
			checker.setGlobal('log', t);
		}
	}
}