package cdblevel;

class DisplayTile
{
	public var tile:Tile;
	public var x:Int = 0;
	public var y:Int = 0;
	public var alpha:Float = 1.0;

	public function new(x : Int, y : Int, t : Tile, ?alpha : Float = 1.0)
	{
		this.x = x;
		this.y = y;
		this.tile = t;
		this.alpha = alpha;
	}
}