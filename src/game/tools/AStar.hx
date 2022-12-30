package tools;

import tools.Point.IPoint;
import tools.Path.IPath;

class Node
{
	public var p : IPoint;
	public var cost : Float = 0;
	public var h : Float = 0;
	public var prev : Node = null;

	public function new(p : IPoint)
	{
		this.p = p;
	}

	public function iterator()
	{
		return new NodeIterator(this);
	}
}

class NodeIterator
{
	var l : Node;

	public inline function new(l : Node)
	{
		MacroTools.initLocals();
	}

	public inline function hasNext()
	{
		return l.prev != null;
	}

	public inline function next()
	{
		var r = l;
		l = l.prev;
		return r;
	}
}

typedef LevelConstraint =
{
	function hasCollision(cx : Int, cy : Int) : Bool;
}

class AStar<T:LevelConstraint>
{
	var level : T;
	var directions : Array<IPoint>;

	public function new(level : T)
	{
		this.level = level;
		directions = [new Point(-1, 0), new Point(1, 0), new Point(0, -1), new Point(0, 1)];
	}

	/**
		Find a path between two points
	**/
	public function getPath(sx : Int, sy : Int, gx : Int, gy : Int) : IPath
	{
		var closed = [];
		var open = [new Node(new IPoint(sx, sy))];

		inline function isInList(p : IPoint, l : Array<Node>) : Node
		{
			var r : Node = null;
			for (node in l)
			{
				if (node.p == p)
				{
					r = node;
					break;
				}
			}
			return r;
		}

		// While there is node to process and we haven't reached the end
		while (open.length > 0)
		{
			var u = open.pop();
			// If we reached the goal, reconstruct the path and return it
			if (u.p.x == gx && u.p.y == gy)
			{
				var path = new IPath();
				for (node in u)
					path.push(node.p);
				path.reverse();
				return path;
			}

			// For each neighbour v of u
			for (d in directions)
			{
				var vp = u.p + d;
				if (level.hasCollision(vp.x, vp.y))
					continue;
				// If we already passed it
				if (isInList(vp, closed) != null)
					continue;
				// If it's already in the open list with a cheaper cost
				var o = isInList(vp, open);
				if (o != null && o.cost <= u.cost)
					continue;
				// We might update it
				if (o == null)
					o = new Node(vp);
				o.cost = u.cost + 1;
				o.h = o.cost + M.iabs(gx - vp.x) + M.iabs(gy - vp.y);
				o.prev = u;
				// Insert in open to keep it sorted based on the heuristic
				var insertAt = 0;
				for (i in 0...open.length)
				{
					if (o.h >= open[i].h)
						break;
					insertAt++;
				}
				open.insert(insertAt, o);
			}
			closed.push(u);
		}
		return [];
	}
}