package;

import kha.Framebuffer;
import kha.Image;
import kha.Color;
import kha.Assets;

class Project {

	private var canvas:Image;

	// object which parses and displays level from CastleDB editor
	private var level:cdblevel.CdbLevel;

	// helper display object which displays collision data of level's tiles
	private var collideGroup:cdblevel.TileGroup;

	// NPC layer
	private var npcs:cdblevel.TileGroup;

	// display layer for showing trigger zones of the level
	private var triggerGroup:cdblevel.TileGroup;

	public function new() 
	{	
		// Loading database from data.cdb file
		var data = Assets.blobs.data_cdb.toString();
		Data.load(data);

		// Get the data of all game levels on `levelData` sheet
		var allLevels = Data.levelData;

		// Loading level data of the first level (with index = 0)
		level = new cdblevel.CdbLevel(allLevels, 0);

        // Just reading layer names on the level
        for (layer in level.layers)
        {
            trace(layer.name);
        }

		// You can get level layer by its name
        var objectsLayer = level.getLevelLayer("objects");

        // let's see levels size in tiles
        trace(level.width);
        trace(level.height);

		// Get the size of tiles
        var tileSize:Int = level.layers[0].tileset.size;

		// we will add npc display object here
        npcs = new cdblevel.TileGroup();

        // Iterating on all npcs objects on the first level
        // `all` is the name of array of all levels in the database
        for (npc in allLevels.all[0].npcs)
        {
            // NPC could have `item` field set, which is a reference to `item` type
			// (reference to the line on `item` sheet)
			if (npc.item != null)
            {
                trace("NPC Item: " + npc.item.id);
            }

            // NPC have `kind` field, which is a reference to `npc` type
            // We are looking for `image` field with the type of `Tile`
            // Tiles have `size`, `file`, `x`, `y`, `?width`, `?height` fields
            var npcImage = npc.kind.image;

            // Get the size of npc's tile
            var npcTileSize = npc.kind.image.size;

            // `width` and `height` are optional
            var npcWidth = (npcImage.width == null) ? 1 : npcImage.width;
            var npcHeight = (npcImage.height == null) ? 1 : npcImage.height;

            // Getting the image of NPC's tile
			var imageName = haxe.io.Path.withoutExtension(npcImage.file);
            var image = Assets.images.get(imageName);
            // And creating display for it
            var npcTileX = npcImage.x * npcTileSize;
            var npcTileY = npcImage.y * npcTileSize;
            var npcTileWidth = npcWidth * npcTileSize;
            var npcTileHeight = npcHeight * npcTileSize;
            var npcTile = new cdblevel.Tile(image);
			npcTile.region = new kha.math.FastVector4(npcTileX, npcTileY, npcTileWidth, npcTileHeight);

            // NPC's position of the screen
            var displayX = tileSize * npc.x - (npcWidth - 1) * npcTileSize;
            var displayY = tileSize * npc.y - (npcHeight - 1) * npcTileSize;
			
			// Adding NPC on the screen
            var displayTile = npcs.add(displayX, displayY, npcTile);
        }

		// Creating tile and tile group for displaying triggers from the editor
		var colorImage = kha.Image.createRenderTarget(16, 16);
		colorImage.g2.begin(true, Color.fromFloats(0.0, 0.0, 1.0, 0.5));
		colorImage.g2.end();

        var colorTile = new cdblevel.Tile(colorImage);
        triggerGroup = new cdblevel.TileGroup();

		// Get the data of `triggers` layer for the level with id `FirstVillage`
		var triggers = allLevels.get(FirstVillage).triggers;

		// Just iterating through zones on this data layer
        for (trigger in triggers)
        {
            // You can use those `action` values anyway you like
			switch (trigger.action)
            {
                case ScrollStop:
                    trace("Stop scrolling the map");
                case Goto(level, anchor):
                    trace('Travel to $level-$anchor');
                case Anchor(label):
                    trace('Anchor zone $label');
                default:

            }

            for (x in 0...trigger.width)
            {
                for (y in 0...trigger.height)
                {
                    triggerGroup.add((trigger.x + x) * tileSize, (trigger.y + y) * tileSize, colorTile);
                }
            }
        }

		// Get the line with id = `Full` from the `collide` sheet
		// read it's icon and load it's image
		var collideImageName = haxe.io.Path.withoutExtension(Data.collide.get(Full).icon.file);
        var collideImage = Assets.images.get(collideImageName); 

        // Create group for displaying collision data
		collideGroup = new cdblevel.TileGroup();
        
        // Read `collide` property from all level's layer:
        var tileProps = level.buildStringProperty("collide");
		// `buildStringProperty()` method returns an Array of strings
		// The length of this arrays is equal to the number of tiles on the level
        // There is also `buildIntProperty()` method, which return and array of Integers
		// You could also read properties of individual layers (with methods which have the same names)

        // Create tiles to display
        for (ty in 0...level.height)
        {
            for (tx in 0...level.width)
            {
                var index = tx + ty * level.width;

                // Tile's property value at (tx, ty) position
                var tileProp = tileProps[index];

                if (tileProp != null)
                {
                    // Read the data from `collide` sheet for current tile
					var collideData = Data.collide.get(cast tileProp);
                    var collideIcon = collideData.icon;
                    var collideSize = collideIcon.size;

                    // create tile
                    var collideTile = new cdblevel.Tile(collideImage).sub(collideIcon.x * collideSize, collideIcon.y * collideSize, collideSize, collideSize);
                    // and add it to display list
                    collideGroup.add(tileSize * tx, tileSize * ty, collideTile, 0.4);
                }
            }
        }

        // Just a Map with tile groups
        var tileGroups = objectsLayer.tileset.groups;

        // Just reading number of tiles in each tile group from the editor
        for (key in tileGroups.keys())
        {
            var group = tileGroups.get(key);
            trace(key + ": " + group.tiles.length);
        }

        trace(tileProps.length);

        // Iterating through all records on `collide` sheet
        /*for (coll in Data.collide.all)
        {
            trace(coll.id);
        }*/

        for (image in Data.images.all)
        {
            var name = image.name;

            // Sample database have sheet `images` with the `stats` column with the type of `Flags`
            // `Flags` objects have `has()` method,  which allows to read individual flag value
            // this way:
            var canClimb = image.stats.has(canClimb);
            // or this way:
            canClimb = image.stats.has(Data.Images_stats.canClimb);
            // reading the values of the rest of the flags
            var canEatBamboo = image.stats.has(canEatBamboo);
            var canRun = image.stats.has(canRun);

            // There is also iterator method for flags
            for (stat in image.stats.iterator())
            {
                trace("stat: " + stat);
            }
            
            trace(name);
            trace("canClimb: " + canClimb);
            trace("canEatBamboo: " + canEatBamboo);
            trace("canRun: " + canRun);
        }

        // Iterating through all npcs
        for (npc in Data.npc.all)
        {
            trace(npc.type);

            // We can do anything we want with npc's type 
			switch (npc.type)
            {
                case Data.Npc_type.Normal:
                    trace("You've met a normal npc");
                case Data.Npc_type.Huge:
                    trace("You've met a HUGE npc");
                default:
                    trace("Ehm, i don't know what to say...");
            }
        }

        // enum, generated by castle library from the database
        trace(Data.Npc_type.Normal);

        // You could read names of all of it's values
        trace(Data.Npc_type.NAMES);

        for (item in Data.item.all)
        {
            trace("item.id: " + item.id);
        }

		canvas = Image.createRenderTarget(kha.System.windowWidth(), kha.System.windowHeight());
		canvas.g2.begin(true, Color.White);
		canvas.g2.end();
	}

	public function update():Void 
	{		
		
	}

	public function render(framebuffer:Framebuffer):Void 
	{
		canvas.g2.begin(false);
		level.draw(canvas);
		collideGroup.draw(canvas);
		triggerGroup.draw(canvas);
		npcs.draw(canvas);
		canvas.g2.end();

		var graphics = framebuffer.g2;
		graphics.begin();
		graphics.drawImage(canvas, 0, 0);
		graphics.end();
	}
}
