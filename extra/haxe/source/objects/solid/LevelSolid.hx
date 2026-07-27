package objects.solid;

import flixel.FlxSprite;
import flixel.util.FlxColor;

using echo.FlxEcho;

class LevelSolid extends FlxSprite
{
    public function new(x:Float, y:Float, width:Int, height:Int)
    {
        super(x, y);
        makeGraphic(width, height, FlxColor.TRANSPARENT);
        solid = true;
        immovable = true;
        this.add_body({x: x + width * 0.5, y: y + height * 0.5, mass: STATIC, shape: {width: width, height: height, type: RECT}, material: {elasticity: 0}});
    }
}