package states;

// anatolystev - adds the coin

import objects.Coin;
import flixel.FlxSprite;
import echo.Body;
import echo.data.Options.WorldOptions;
import echo.World;
import creatures.player.Tux;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import states.substates.LevelIntro;
import tools.LevelLoader;

using echo.FlxEcho;

class PlayState extends FlxState
{
	public var map:FlxTilemap;
	public var uhoh:Int = 1; // Tiled's Global IDs thing makes this more complicated than it should be. See ForestTux PlayState for more info. Although, warning, there is a bit of swearing there.

	public var tux(default, null):Tux;
	public var solidThings:FlxGroup;
	public var entities:FlxGroup;

	var hud:HUD;

	public var checkpoint:FlxPoint;

	override public function create()
	{
		// Just so Global.PS actually works...
		Global.PS = this;

		FlxG.mouse.visible = false;

		// Allows for a very high level width / height (3124 tiles)
		FlxEcho.init({width: 99999, height: 99999, gravity_y: 1000});

		// Add things part 2
		solidThings = new FlxGroup();
		entities = new FlxGroup();
		tux = new Tux();
		hud = new HUD();

		LevelLoader.loadLevel(this, Global.currentLevel);
		
		tux.currentState = Global.tuxState;
		tux.reloadGraphics();

		// Add things part 3
		add(solidThings);
		add(entities);
		add(tux);
		add(hud);

		// Camera
		FlxG.camera.follow(tux, PLATFORMER);
		FlxG.camera.setScrollBoundsRect(0, 0, map.width, map.height, true);

		// Read Foreground Layer comment below. Also each level shall have, at maximum, only one secret wall, although there really shouldn't be any.
		var secretLayer:TiledTileLayer = cast LevelLoader.tiledMap.getLayer("Secret");
        
        var secretMap = new FlxTilemap();
        secretMap.loadMapFromArray(secretLayer.tileArray, LevelLoader.tiledMap.width, LevelLoader.tiledMap.height, "assets/images/tiles.png", 32, 32, uhoh);
        secretMap.solid = false;

		// Foreground Layer, just realized I added this in the worst way possible. Oh well, too bad! 
		// (Comment from ForestTux, where this code came from. ForestTux is another scrapped project of mine)
		var foregroundLayer:TiledTileLayer = cast LevelLoader.tiledMap.getLayer("Foreground");
        
        var foregroundMap = new FlxTilemap();
        foregroundMap.loadMapFromArray(foregroundLayer.tileArray, LevelLoader.tiledMap.width, LevelLoader.tiledMap.height, "assets/images/tiles.png", 32, 32, uhoh);
        foregroundMap.solid = false;

		add(foregroundMap);
		add(secretMap);

		// Start the level intro
		openSubState(new LevelIntro(FlxColor.BLACK));

		trace(Global.checkpointReached);

		super.create();

		// Tux collision
		FlxEcho.listen(solidThings, tux);
		FlxEcho.listen(entities, tux, {separate: false, enter: (bodyA:Body, bodyB:Body, _) -> { // AnatolyStev
			var spriteA:FlxSprite = cast bodyA.object;
			var spriteB:FlxSprite = cast bodyB.object;

			var entity = (spriteA == tux) ? spriteB : spriteA;

			collideEntities(entity);
		}});
	}

	// AnatolyStev
	function collideEntities(entity:FlxSprite) 
	{
		if (Std.isOfType(entity, Coin))
		{
			cast(entity, Coin).collect();
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		updateCheckpoint();
	}

	function updateCheckpoint()
	{
		if (checkpoint == null || Global.checkpointReached)
		{
			return;
		}

		if (tux.x >= checkpoint.x)
		{
			trace("Checkpoint reached!");
			Global.checkpointReached = true;
			trace(Global.checkpointReached);
		}
	}
}
