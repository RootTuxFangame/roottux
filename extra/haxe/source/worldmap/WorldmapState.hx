package worldmap;

// Made by AnatolyStev, worldmap PlayState.
// Improved by Vaesea to remove rock position stuff.

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import states.PlayState;

class WorldmapState extends FlxState
{
    public var map:FlxTilemap;

	public var collision(default, null):FlxTypedGroup<FlxSprite>;
	public var tux(default, null):WMTux;
	public var levels(default, null):FlxTypedGroup<Level>;
    public var rocks(default, null):FlxTypedGroup<Rock>;

    override public function create()
    {
        FlxG.mouse.visible = false;
        
        if (FlxG.sound.music != null) // Check if song is playing, if it is, stop song. This if statement is here just to avoid a really weird crash.
        {
            FlxG.sound.music.stop();
        }

        Global.WMS = this;

        // Add things part 1
        collision = new FlxTypedGroup<FlxSprite>();
        levels = new FlxTypedGroup<Level>();
        rocks = new FlxTypedGroup<Rock>();
        tux = new WMTux();
        
        var numberOfWorldmap = Global.worldmaps[Global.currentWorldmap];

        WorldmapLoader.loadWorldmap(this, numberOfWorldmap);
        
        checkRockUnlocks();

        // Add things part 2
        add(collision);
        add(levels);
        add(rocks);
        add(tux);

        if (Global.tuxWorldmapX != 0 || Global.tuxWorldmapY != 0)
        {
            tux.x = Global.tuxWorldmapX;
            tux.y = Global.tuxWorldmapY;
        }

        FlxG.camera.follow(tux, TOPDOWN, 1.0);
        FlxG.camera.setScrollBoundsRect(0, 0, map.width, map.height, true);

        if (Global.currentSong != null) // If it's null and this isn't done, the game will crash.
        {
            FlxG.sound.playMusic(Global.currentSong, 1.0, true);
        }
    }

    public function checkRockUnlocks()
    {
        for (rock in rocks)
        {
            if (rock.isGone) 
            {
                continue;
            }

            if (sectionCompleted(rock.rockSection))
            {
                rock.removeRock();
            }
        }
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        // Tux collision
        FlxG.collide(collision, tux);
        FlxG.collide(rocks, tux);
        FlxG.overlap(tux, levels, overlapLevels);

        for (square in levels)
        {
            if (Global.completedLevels.contains(square.ldLevelPath))
            {
                square.completeLevel();
            }
        }

        // Is this needed?
        for (rock in rocks)
        {
            if (rock.isGone)
            {
                continue;
            }

            if (sectionCompleted(rock.rockSection))
            {
                rock.removeRock();
            }
        }
    }

    function overlapLevels(tux:WMTux, square:FlxSprite)
    {
        if (Std.isOfType(square, Level))
        {
            var level:Level = cast square; // I did a REALLY complicated thing here and I'm NOT even sure if it's needed (note from vaesea -> is it really that complicated? it's just a cast [thing]...)

            Global.dotLevelName = level.ldDisplayName;

            if (FlxG.keys.anyJustPressed([SPACE, ENTER]))
            {
                Global.tuxWorldmapX = tux.x;
                Global.tuxWorldmapY = tux.y;
                Global.saveProgress();

                Global.currentLevel = level.ldLevelPath;
                Global.currentSection = level.ldSection;

                Global.checkpointReached = false;

                FlxG.switchState(PlayState.new);
            }
        }
    }

    function sectionCompleted(section:String)
    {
        for (square in levels)
        {
            if (square.ldSection == section && !Global.completedLevels.contains(square.ldLevelPath))
            {
                return false;
            }
        }
        return true;
    }

    override public function destroy() 
    {
        Global.saveProgress();
        super.destroy();
    }
}