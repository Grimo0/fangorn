package tools;

abstract Resolution({w : Int, h : Int}) from {w : Int, h : Int} to {w : Int, h : Int}
{
	public static var list : Array<Resolution> = [
		{w: 1024, h: 600},
		{w: 1024, h: 640},
		{w: 1024, h: 768},
		{w: 1024, h: 800},
		{w: 1280, h: 720},
		{w: 1280, h: 768},
		{w: 1280, h: 800},
		{w: 1280, h: 960},
		{w: 1366, h: 768},
		{w: 1440, h: 900},
		{w: 1440, h: 960},
		{w: 1440, h: 1080},
		{w: 1600, h: 900},
		{w: 1600, h: 1200},
		{w: 1680, h: 1050},
		{w: 1792, h: 1344},
		{w: 1856, h: 1392},
		{w: 1920, h: 1080},
		{w: 1920, h: 1200},
		{w: 1920, h: 1280},
		{w: 1920, h: 1440},
		{w: 2048, h: 1280},
		{w: 2048, h: 1536},
		{w: 2160, h: 1440},
		{w: 2304, h: 1728},
		{w: 2560, h: 1440},
		{w: 2560, h: 1600},
		{w: 2560, h: 1700},
		{w: 2560, h: 1920},
	];

	public var w(get, set) : Int;
	inline function get_w() : Int return this.w;
	inline function set_w(value : Int) : Int return this.w = value;

	public var h(get, set) : Int;
	inline function get_h() : Int return this.h;
	inline function set_h(value : Int) : Int return this.h = value;

	public var ratio(get, never) : Float;
	inline function get_ratio() : Float return this.w / this.h;

	public inline function new(w : Int, h : Int)
	{
		this = {w: w, h: h};
	}

	@:op(A == B)
	public inline function equals(r : Resolution)
	{
		return this.w == r.w && this.h == r.h;
	}

	public static function indexOf(r : Resolution) : Int
	{
		for (i in 0...list.length)
		{
			if (r == list[i])
				return i;
		}
		return -1;
	}

	@:to
	public inline function toString() : String
	{
		#if debug
		return '${w}x$h(${ratio.f2Dec()})';
		#else
		return '${w}x$h';
		#end
	}
}