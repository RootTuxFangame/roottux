package worldmap;

// Made by AnatolyStev, loads Worldmap.

import flixel.FlxState;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.tile.FlxTilemap;
import objects.solid.WorldmapSolid;
import worldmap.Level;
import worldmap.WorldmapState;

class WorldmapLoader extends FlxState
{
    public static function loadWorldmap(state:WorldmapState, worldmap:String)
    {
        var tiledMap = new TiledMap("assets/data/worldmaps/" + worldmap + ".tmx");

        var uhoh = 1; // if you saw playstate, you know what this is.

        var song = tiledMap.properties.get("Music");
        var worldmapName = tiledMap.properties.get("Worldmap Name");

        Global.currentSong = song;
        Global.worldmapName = worldmapName;

        // Water
        var waterLayer:TiledTileLayer = cast tiledMap.getLayer("Water");

        var waterMap = new FlxTilemap();
        waterMap.loadMapFromArray(waterLayer.tileArray, tiledMap.width, tiledMap.height, "assets/images/tiles.png", 32, 32, uhoh);
        waterMap.solid = false;

        // Main
        var mainLayer:TiledTileLayer = cast tiledMap.getLayer("Main");

        state.map = new FlxTilemap();
        state.map.loadMapFromArray(mainLayer.tileArray, tiledMap.width, tiledMap.height, "assets/images/tiles.png", 32, 32, uhoh);
        state.map.solid = false;

        // Foreground 1
        var foregroundOneLayer:TiledTileLayer = cast tiledMap.getLayer("Decorations");
        
        var foregroundOneMap = new FlxTilemap();
        foregroundOneMap.loadMapFromArray(foregroundOneLayer.tileArray, tiledMap.width, tiledMap.height, "assets/images/tiles.png", 32, 32, uhoh);
        foregroundOneMap.solid = false;

        state.add(waterMap);
        state.add(state.map);
        state.add(foregroundOneMap);

        for (solid in getLevelObjects(tiledMap, "Solid"))
        {
            var solidSquare = new WorldmapSolid(solid.x, solid.y, solid.width, solid.height); // Need this because width and height.
            state.collision.add(solidSquare);
        }

        for (object in getLevelObjects(tiledMap, "Levels"))
        {
            var levelPath = object.properties.get("file");
            var section = object.properties.get("section");
            var displayName = object.properties.get("displayName");

            var levelDot = new Level(object.x, object.y - 32);
            levelDot.setup(levelPath, section, displayName);
            state.levels.add(levelDot);
        }

        for (object in getLevelObjects(tiledMap, "Rocks"))
        {
            var section = object.properties.get("section");
            
            var rock = new Rock(object.x, object.y - 32);
            rock.theRock(section);
            state.rocks.add(rock);
        }

        var tuxPosition:TiledObject = getLevelObjects(tiledMap, "Player")[0];
        
        if (Global.tuxWorldmapX == 0 && Global.tuxWorldmapY == 0)
        {
            state.tux.setPosition(tuxPosition.x, tuxPosition.y - 6);
        }
        else
        {
            state.tux.setPosition(Global.tuxWorldmapX, Global.tuxWorldmapY);
        }
    }

    public static function getLevelObjects(map:TiledMap, layer:String):Array<TiledObject>
    {
        if ((map != null) && (map.getLayer(layer) != null))
        {
            var objLayer:TiledObjectLayer = cast map.getLayer(layer);
            return objLayer.objects;
        }
        else
        {
            trace("Object layer " + layer + " not found! Also credits to Discover Haxeflixel.");
            return [];
        }
    }
}