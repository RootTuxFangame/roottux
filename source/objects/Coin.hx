package objects;

import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;

using echo.FlxEcho;

class Coin extends FlxSprite
{
    var coinImage = FlxAtlasFrames.fromSparrow("assets/images/objects/coin.png", "assets/images/objects/coin.xml");

    public function new(x:Float, y:Float)
    {
        super(x, y);

        frames = coinImage;
        animation.addByPrefix("normal", "normal", 12, true);
        animation.play("normal");

        this.add_body({x: this.x + width * 0.5, y: this.y + height * 0.5, mass: STATIC, shape: {type: CIRCLE, radius: 16}, material: {gravity_scale: 0}});
    }

    override public function update(elapsed:Float)
    {
        this.get_body().x = this.x + width * 0.5;
        this.get_body().y = this.y + height * 0.5;
        super.update(elapsed);
    }

    public function collect()
    {
        this.get_body().active = false;
        Global.coins += 1;
        FlxG.sound.play("assets/sounds/coin.wav");
        FlxTween.tween(this, {alpha: 0, y: y -64}, 0.25, {onComplete: finishKill});
    }

    function finishKill(_)
    {
        kill();
        this.remove_object();
    }

    public function setFromBlock()
    {
        FlxG.sound.play("assets/sounds/coin.wav");
        solid = false;
        Global.coins += 1;
        FlxTween.tween(this, {alpha: 0, y: y -64}, 0.25, {onComplete: finishKill});
    }
}