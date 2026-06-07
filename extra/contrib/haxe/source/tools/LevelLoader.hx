package tools;

import creatures.badguy.SnowballNoEcho;
import creatures.badguy.Snowball;
import objects.Coin;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.editors.tiled.TiledImageLayer;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import objects.solid.LevelSolid;
import states.PlayState;

using echo.FlxEcho;

class LevelLoader extends FlxState
{
    public static var tiledMap:TiledMap;

    public static function loadLevel(state:PlayState, level:String)
    {
        tiledMap = new TiledMap("assets/data/levels/" + level + ".tmx");

        var music = tiledMap.properties.get("Music");
        var levelName = tiledMap.properties.get("Level Name");
        var levelCreator = tiledMap.properties.get("Level Creator");

        Global.currentSong = music;
        Global.levelName = levelName;
        Global.levelCreator = levelCreator;

        // Quickly taken from Adel Time (Old) / ForestTux / Tux Platforming / PepperTux Haxe. If I forgot one, you could probably tell me idk
        for (layer in tiledMap.layers)
        {
            if (Std.isOfType(layer, TiledImageLayer))
            {
                var imageLayer:TiledImageLayer = cast layer;
                var path:String = Std.string(imageLayer.imagePath);
                path = StringTools.replace(path, "../", "");
                path = "assets/" + path;

                var image = new FlxBackdrop(path, XY);

                image.offset.x = 0.0;
                image.offset.y = 0.0;
                
                image.scrollFactor.x = imageLayer.parallaxX;
                image.scrollFactor.y = imageLayer.parallaxY;

                state.add(image);

                trace(path); // This is here so you can see if the path is correct if the image isn't showing.
            }
        }

        var mainLayer:TiledTileLayer = cast tiledMap.getLayer("Interactive");

        state.map = new FlxTilemap();
        state.map.loadMapFromArray(mainLayer.tileArray, tiledMap.width, tiledMap.height, "assets/images/tiles.png", 32, 32, state.uhoh); // tiled is bad and i have to start at global id 42- nope! 49 now.
        state.map.solid = false;

        var backgroundLayer:TiledTileLayer = cast tiledMap.getLayer("Background");
        
        var backgroundMap = new FlxTilemap();
        backgroundMap.loadMapFromArray(backgroundLayer.tileArray, tiledMap.width, tiledMap.height, "assets/images/tiles.png", 32, 32, state.uhoh);
        backgroundMap.solid = false;

        state.add(backgroundMap);
        state.add(state.map);

        var tuxThing:TiledObject = getLevelObjects(tiledMap, "Player")[0];
        var tuxPosition:FlxPoint = new FlxPoint(tuxThing.x, tuxThing.y);
        if (Global.checkpointReached)
        {
            tuxPosition = state.checkpoint;
        }
        else
        {
            tuxPosition.set(tuxThing.x, tuxThing.y);
        }

        var tux_body = FlxEcho.get_body(state.tux);

        tux_body.x = tuxPosition.x;
        tux_body.y = tuxPosition.y - 64;

        for (solid in getLevelObjects(tiledMap, "Solid"))
        {
            var solidSquare = new LevelSolid(solid.x, solid.y, solid.width, solid.height); // Need this because width and height.
            solidSquare.add_to_group(state.solidThings);
        }

        for (object in getLevelObjects(tiledMap, "Objects"))
        {
            switch (object.type)
            {
                case "coin":
                    var coin:Coin = new Coin(object.x, object.y - 32);
                    coin.add_to_group(state.entities);
            }
        }

        for (object in getLevelObjects(tiledMap, "Badguys"))
        {
            switch (object.type)
            {
                default:
                    var snowball:SnowballNoEcho = new SnowballNoEcho(object.x, object.y - 32);
                    state.badguys.add(snowball);
            }
        }
    }

    // copied from too many projects of mine, but is originally from Discover HaxeFlixel.
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