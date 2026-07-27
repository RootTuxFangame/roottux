package creatures.badguy;

import flixel.graphics.frames.FlxAtlasFrames;

class SnowballNoEcho extends BadguyNoEcho
{
    var snowballImage = FlxAtlasFrames.fromSparrow("assets/images/creatures/snowball.png", "assets/images/creatures/snowball.xml");

    public function new(x:Float, y:Float)
    {
        super(x, y);

        frames = snowballImage;
        animation.addByPrefix('walk', 'walk', 10, true);
        animation.addByPrefix('squished', 'squished', 10, false);
        animation.play('walk');

        setSize(30, 32);
        offset.set(4, 4);

        acceleration.y = gravity;
    }

    override private function move()
    {
        velocity.x = direction * walkSpeed;
    }
}