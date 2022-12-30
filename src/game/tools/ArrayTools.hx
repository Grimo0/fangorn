package tools;

class ArrayTools
{
	/**
		Return the index of the first element for which `test` returns `true`.
	**/
	static public function search<T>(a : Array<T>, test : T->Bool) : Int
	{
		for (i in 0...a.length)
		{
			if (test(a[i]))
				return i;
		}
		return -1;
	}

	/**
		Add all the elements of `b` at the end of `a` and return it. This doesn't modify `b`. 
	**/
	static public function pushAll<T>(a : Array<T>, b : Array<T>) : Array<T>
	{
		var aOldLength = a.length;
		a.resize(a.length + b.length);
		for (i in aOldLength...a.length)
		{
			a[i] = b[i - aOldLength];
		}
		return a;
	}
}