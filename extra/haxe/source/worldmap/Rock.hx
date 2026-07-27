package worldmap;

// Made by AnatolyStev

import flixel.FlxSprite;

class Rock extends FlxSprite
{
    public var rockSection:String; // Why isn't this an int or float?
    public var isGone = false;

    public function new(x:Float, y:Float)
    {
        super(x, y);

        // Load image
        loadGraphic("assets/images/worldmap/rock.png", false);

        // Make solid and immovable
        solid = true;
        immovable = true;
    }

    // Add the rock. Not that "the rock"
    public function theRock(section:String)
    {
        rockSection = section;
    }
    
    // Delete rock from worldmap
    public function removeRock()
    {
        if (isGone)
        {
            return;
        }

        isGone = true;
        kill();
    }
}