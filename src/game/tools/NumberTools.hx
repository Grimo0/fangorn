package tools;

class NumberTools
{
	static public inline function iSpaced(v : Int) : String
	{
		var higherDigits = Std.int(v / 1000);
		var rest = v - higherDigits * 1000;
		var res = '$rest';
		v = higherDigits;
		while (higherDigits > 0)
		{
			higherDigits = Std.int(v / 1000);
			rest = v - higherDigits * 1000;
			res = '$rest $res';
			v = higherDigits;
		}
		return res;
	}

	static public inline function fSpaced(v : Float) : String
	{
		var fractions = v - Std.int(v);
		if (fractions == 0)
			return iSpaced(Std.int(v));
		return iSpaced(Std.int(v)) + fractions;
	}

	static public inline function f2Dec(v : Float) : Float
	{
		return Std.int(v * 100) / 100;
	}

	static public inline function f3Dec(v : Float) : Float
	{
		return Std.int(v * 1000) / 1000;
	}

	static public inline function f4Dec(v : Float) : Float
	{
		return Std.int(v * 10000) / 10000;
	}
}