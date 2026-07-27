package objects.solid;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class WorldmapSolid extends FlxSprite
{
    public function new(x:Float, y:Float, width:Int, height:Int)
    {
        super(x, y);
        makeGraphic(width, height, FlxColor.TRANSPARENT);
        solid = true;
        immovable = true;
    }
}