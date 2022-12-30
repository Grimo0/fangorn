package s3d;

enum abstract MeshAlign(Int) from Int to Int
{
	var Top = 1 << 0;
	var Bottom = 1 << 1;
	var Left = 1 << 2;
	var Right = 1 << 3;
}

class BillboardMesh
{
	/**
	 * @param align If null will be centered
	 */
	public static function createFromTex(tex : h3d.mat.Texture, w : Float, h : Float, ?align : Null<MeshAlign>, ?uvs : Array<h3d.prim.UV>, ?parent : h3d.scene.Object)
	{
		var mat = h3d.mat.Material.create(tex);
		mat.shadows = false;
		mat.blendMode = Alpha;
		mat.mainPass.enableLights = false;
		mat.mainPass.addShader(new shaders.BillboardShader());

		var p = [
			new h3d.col.Point(0, 0, 0),
			new h3d.col.Point(w, 0, 0),
			new h3d.col.Point(0, -h, 0),
			new h3d.col.Point(w, -h, 0),
		];
		if (uvs == null)
			uvs = [
				new h3d.prim.UV(0, 0),
				new h3d.prim.UV(1, 0),
				new h3d.prim.UV(0, 1),
				new h3d.prim.UV(1, 1)
			];
		var quads = new h3d.prim.Quads(p, uvs);
		if (align == null)
			quads.translate(-w / 2, h / 2, 0);
		else
		{
			if (align & Top == 0 || align & Left == 0)
				quads.translate(
					align & Right != 0 ? -w : align & Left == 0 ? -w / 2 : 0,
					align & Bottom != 0 ? h : align & Top == 0 ? h / 2 : 0,
					0);
		}
		quads.addNormals();

		var mesh = new h3d.scene.Mesh(quads, mat, parent);
		return mesh;
	}

	/**
	 * @param align If null will be centered
	 */
	@:access(h2d.Tile)
	public static function createFromTile(tile : h2d.Tile, w : Float, h : Float, ?align : Null<MeshAlign>, ?parent : h3d.scene.Object)
	{
		var tex = tile.getTexture();
		return createFromTex(tex, w, h, align, [
			new h3d.prim.UV(tile.u, tile.v),
			new h3d.prim.UV(tile.u2, tile.v),
			new h3d.prim.UV(tile.u, tile.v2),
			new h3d.prim.UV(tile.u2, tile.v2)
		], parent);
	}
}