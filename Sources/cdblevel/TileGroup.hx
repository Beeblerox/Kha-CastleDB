package cdblevel;

import kha.Canvas;

class TileGroup
{
	public var x : Float = 0.0;
	public var y : Float = 0.0;

	private var data:Array<DisplayTile>;

	public function new() {
		data = [];
	}

	public inline function add(x : Int, y : Int, t : Tile, ?alpha : Float = 1.0) : DisplayTile
	{
		var display = new DisplayTile(x, y, t, alpha);
		data.push(display);
		return display;
	}

	public function clear() : Void {
		data = [];
	}

	public function draw(canvas:Canvas):Void
	{
		var graphics = canvas.g2;

		var c = graphics.color;
		var currentAlpha = c.A;

		for (tile in data)
		{
			if (currentAlpha != tile.alpha)
			{
				currentAlpha = tile.alpha;
				graphics.color = kha.Color.fromFloats(1.0, 1.0, 1.0, tile.alpha);
			}

			graphics.drawSubImage(tile.tile.image, x + tile.x, y + tile.y, tile.tile.x, tile.tile.y, tile.tile.width, tile.tile.height);
		}

		graphics.color = c;
	}
}