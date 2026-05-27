package objects;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;

using echo.FlxEcho;

class Coin extends FlxSprite
{
    var speedFromBlock = -128;
    var coinImage = FlxAtlasFrames.fromSparrow("assets/images/objects/coin.png", "assets/images/objects/coin.xml");

    public function new(x:Float, y:Float)
    {
        super(x, y);

        frames = coinImage;
        animation.addByPrefix("normal", "normal", 12, true);
        animation.play("normal");

        this.add_body({x: this.x, y: this.y, mass: STATIC, shape: {type: CIRCLE, radius: 32}, material: {gravity_scale: 0}});
    }

    public function collect()
    {
        alive = false;
        solid = false;
        trace("Tux collects the coin!");
    }
}