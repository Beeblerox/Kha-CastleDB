package cdblevel;

import kha.Image;
import kha.math.FastVector4;

class Tile
{
	public var image:Image;
	public var region:FastVector4;

	public var x(get, null):Int;
	public var y(get, null):Int;
	public var width(get, null):Int;
	public var height(get, null):Int;

	public function new(image:Image)
	{
		this.image = image;
		region = new FastVector4(0, 0, image.width, image.height);
	}

	public function sub(x: Int, y : Int, w : Int, h : Int ) : Tile 
	{
		var t = new Tile(image);
		t.region = new FastVector4(region.x + x, region.y + y, w, h);
		return t;
	}

	public function gridFlatten(size : Int):Array<Tile>
	{
		return [for( y in 0...Std.int(height / size) ) for( x in 0...Std.int(width / size) ) sub(x * size, y * size, size, size)];
	}

	private inline function get_x():Int
	{
		return Std.int(region.x);
	}

	private inline function get_y():Int
	{
		return Std.int(region.y);
	}

	private inline function get_width():Int
	{
		return Std.int(region.z);
	}

	private inline function get_height():Int
	{
		return Std.int(region.w);
	}
}