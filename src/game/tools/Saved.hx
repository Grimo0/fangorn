package tools;

class Saved
{
	@:access(haxe.Serializer)
	@:keep
	function hxSerialize(u : haxe.Serializer)
	{
		for (f in Reflect.fields(this))
		{
			u.serializeString(f);
			u.serialize(Reflect.field(this, f));
		}
	}

	@:access(haxe.Unserializer)
	@:keep
	function hxUnserialize(u : haxe.Unserializer)
	{
		while (true)
		{
			if (u.pos >= u.length)
				throw "Invalid object";
			if (u.get(u.pos) == "g".code)
				break;
			var k : Dynamic = u.unserialize();
			if (!Std.isOfType(k, String))
				throw "Invalid object key";
			var v = u.unserialize();
			if (Reflect.hasField(this, k))
				Reflect.setField(this, k, v);
		}
	}
}