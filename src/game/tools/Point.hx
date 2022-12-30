package tools;

typedef FPoint = Point<Float>;
typedef IPoint = Point<Int>;

abstract Point<T:Float>({x : T, y : T}) from {x : T, y : T} to {x : T, y : T}
{
	public var x(get, set) : T;
	inline function get_x() : T return this.x;
	inline function set_x(value : T) : T return this.x = value;

	public var y(get, set) : T;
	inline function get_y() : T return this.y;
	inline function set_y(value : T) : T return this.y = value;

	public inline function new(x : T, y : T)
	{
		this = {x: x, y: y};
	}

	public inline function copy() : Point<T> return new Point(x, y);

	public var length(get, never) : Float;
	public inline function get_length() return Math.sqrt(x * x + y * y);

	public var lengthSq(get, never) : T;
	public inline function get_lengthSq() return x * x + y * y;

	public inline function dot(p : Point<T>) return this.x * p.x + this.y * p.y;

	public inline function manhattan(p : IPoint) return M.iabs(cast this.x - p.x) + M.iabs(cast this.y - p.y);

	public inline function cross(p : Point<T>) return this.x * p.y - this.y * p.x;

	public inline function distToSq(x : T, y : T) return (this.x - x) * (this.x - x) + (this.y - y) * (this.y - y);
	public inline function distToPSq(p : Point<T>) return distToSq(p.x, p.y);
	public inline function distTo(x : T, y : T) return Math.sqrt(distToSq(x, y));
	public inline function distToP(p : Point<T>) return distTo(p.x, p.y);

	public inline function normalize()
	{
		var k : Float = lengthSq;
		if (k < hxd.Math.EPSILON) k = 0 else k = M.invSqrt(k);
		x = cast(x * k);
		y = cast(y * k);
	}

	/** Angle in radians to something else **/
	public inline function angTo(x : T, y : T) return Math.atan2(y - this.y, x - this.x);
	/** Angle in radians to something else **/
	public inline function angToP(p : Point<T>) return angTo(p.x, p.y);

	/**
	 * The sign of the acute angle between 1->2 and 1->this
	 * @param p1 
	 * @param p2 
	 * @return T 0 if this is on the line, 1 if this is on the right of A->B, -1 if on the left
	 */
	public inline function sideOf(p1 : Point<T>, p2 : Point<T>) : T
	{
		var c : Float = (p2.x - p1.x) * (y - p1.y) - (p2.y - p1.y) * (x - p1.x);
		return cast c == 0 ? 0 : c > 0 ? 1 : -1;
	}

	@:access(h2d.Object)
	public inline function fromObjToGlobal(o : h2d.Object) : Point<T>
	{
		@:privateAccess o.syncPos();
		var oldX = x;
		x = cast oldX * o.matA + y * o.matC + o.absX;
		y = cast oldX * o.matB + y * o.matD + o.absY;
		return this;
	}

	@:access(h2d.Object)
	public inline function fromGlobalToObj(o : h2d.Object) : Point<T>
	{
		@:privateAccess o.syncPos();
		var dx = x - o.absX;
		var dy = y - o.absY;
		var invDet = 1 / (o.matA * o.matD - o.matB * o.matC);
		x = cast(dx * o.matD - dy * o.matC) * invDet;
		y = cast(-dx * o.matB + dy * o.matA) * invDet;
		return this;
	}

	@:op(A * B) @:commutative
	public inline function tMul(v : T)
	{
		return new Point<T>(this.x * v, this.y * v);
	}

	@:op(A / B) @:commutative
	public inline function tDiv(v : T)
	{
		return new FPoint(this.x / v, this.y / v);
	}

	@:op(A + B) @:commutative
	public inline function tAdd(v : T)
	{
		return new Point<T>(this.x + v, this.y + v);
	}

	@:op(A - B) @:commutative
	public inline function tSub(v : T)
	{
		return new Point<T>(this.x - v, this.y - v);
	}

	@:op(A * B)
	public inline static function time<T : Float, M : Float, N : Float>(p1 : Point<M>, p2 : Point<N>) : Point<T>
	{
		return new Point<T>(cast p1.x * p2.x, cast p1.y * p2.y);
	}

	@:op(A + B)
	public inline static function add<T : Float, M : Float, N : Float>(p1 : Point<M>, p2 : Point<N>) : Point<T>
	{
		return new Point<T>(cast p1.x + p2.x, cast p1.y + p2.y);
	}

	@:op(A - B)
	public inline static function sub<T : Float, M : Float, N : Float>(p1 : Point<M>, p2 : Point<N>) : Point<T>
	{
		return new Point<T>(cast p1.x - p2.x, cast p1.y - p2.y);
	}

	@:op(A == B)
	public inline static function eqf<M : Float, N : Float>(p1 : Point<M>, p2 : Point<N>) : Bool
	{
		return (p1.x == cast p2.x) && (p1.y == cast p2.y);
	}

	@:op(A == B)
	public inline static function eqi<M : Int, N : Int>(p1 : Point<M>, p2 : Point<N>) : Bool
	{
		return (p1.x == cast p2.x) && (p1.y == cast p2.y);
	}

	@:op(A != B)
	public inline static function neq<M : Float, N : Float>(p1 : Point<M>, p2 : Point<N>) : Bool
	{
		return (p1.x != cast p2.x) || (p1.y != cast p2.y);
	}

	@:from
	static public inline function fromIPoint<T : Float>(v : IPoint) : Point<T>
	{
		return v != null ? new Point<T>(cast v.x, cast v.y) : null;
	}

	@:to
	static public inline function toIPoint<T : Float>(v : Point<T>) : IPoint
	{
		return v != null ? new IPoint(Std.int(v.x), Std.int(v.y)) : null;
	}

	@:from
	static public inline function fromFPoint<T : Float>(v : FPoint) : Point<T>
	{
		return v != null ? new Point<T>(cast v.x, cast v.y) : null;
	}

	@:to
	static public inline function toFPoint<T : Float>(v : Point<T>) : FPoint
	{
		return v != null ? new FPoint(v.x, v.y) : null;
	}

	@:from
	static public inline function fromT<T : Float>(v : T) : Point<T>
	{
		return v != null ? new Point(v, v) : null;
	}

	@:from
	static public inline function fromH2dColIPoint(v : h2d.col.IPoint)
	{
		return v != null ? new Point(v.x, v.y) : null;
	}

	@:to
	public inline function toH2dColIPoint() : h2d.col.IPoint
	{
		return new h2d.col.IPoint(cast x, cast y);
	}

	@:from
	static public inline function fromH2dColPoint(v : h2d.col.Point)
	{
		return v != null ? new Point(v.x, v.y) : null;
	}

	@:to
	public inline function toH2dColPoint() : h2d.col.Point
	{
		return new h2d.col.Point(x, y);
	}

	#if hlimgui
	@:from
	static public inline function fromImVec2<T : Float>(v : imgui.ImGui.ImVec2) : Point<T>
	{
		return v != null ? new Point<T>(cast v.x, cast v.y) : null;
	}

	@:to
	public inline function toImVec2() : imgui.ImGui.ImVec2
	{
		return {x: cast(this.x, Single), y: cast(this.y, Single)};
	}
	#end
}