
class Boot {
	public static function main() {
		haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos) {}

		var packer : Packer;
		#if texture
		packer = new TexturePacker();
		#else
		packer = new Packer();
		#end
		packer.run();
	}
}