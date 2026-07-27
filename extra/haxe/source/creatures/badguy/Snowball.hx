package creatures.badguy;

import flixel.graphics.frames.FlxAtlasFrames;

using echo.FlxEcho;

class Snowball extends Badguy
{
    var gravity = 1000;

    var snowballImage = FlxAtlasFrames.fromSparrow("assets/images/creatures/snowball.png", "assets/images/creatures/snowball.xml");

    public function new(x:Float, y:Float)
    {
        super(x, y);

        frames = snowballImage;
        animation.addByPrefix('walk', 'walk', 10, true);
        animation.addByPrefix('squished', 'squished', 10, false);
        animation.play('walk');

        offset.set(0, 2); // half of what it was in peppertux-haxe due to echo-flixel

        this.add_body({x: this.x, y: this.y, mass: 1.0, shape: {type: RECT, width: 30, height: 32}, material: {elasticity: 0.0}}); // TODO: Is the elasticity thing needed? It seems to be set to 0 by default...
    }

    override private function move()
    {
        this.get_body().velocity.x = direction * walkSpeed;
    }
}