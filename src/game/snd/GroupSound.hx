package snd;

/**
	Countains a list of sound and choose one randomly when played.
**/
class GroupSound extends hxd.res.Sound
{
	var serie : Array<hxd.res.Sound>;

	public inline function hasSerie()
	{
		return serie != null;
	}

	public function pick() : hxd.res.Sound
	{
		if (serie == null) return this;
		return serie[Std.random(serie.length)];
	}

	override public function play(?loop = false, ?volume = 1., ?channelGroup, ?soundGroup)
	{
		if (serie == null) return super.play(loop, volume, channelGroup, soundGroup);
		var s = pick();
		return s.play(loop, volume, channelGroup, soundGroup);
	}
}