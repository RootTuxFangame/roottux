package worldmap;

// Made by AnatolyStev

import flixel.FlxG;
import flixel.FlxSprite;

class WMTux extends FlxSprite
{
    // Speed
    var walkSpeed = 128;
    var runSpeed = 192;
    var speed = 0; // Don't change this

    // Deceleration
    var deceleration = 1600;

    public function new()
    {
        super();

        // Load image
        loadGraphic("assets/images/worldmap/bigtux.png", false);

        // Add deceleration
        drag.set(deceleration, deceleration);

        // Hitbox
        setSize(27, 11);
        offset.set(0, 21);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        // Running and walking
        if (FlxG.keys.pressed.CONTROL)
        {
            speed = runSpeed;
        }
        else
        {
            speed = walkSpeed;
        }

        // Controls (left and right)
        if (FlxG.keys.anyPressed([LEFT, A]))
        {
            velocity.x = -speed;
        }
        else if (FlxG.keys.anyPressed([RIGHT, D]))
        {
            velocity.x = speed;
        }
        
        // Controls (down and up)
        if (FlxG.keys.anyPressed([DOWN, S]))
        {
            velocity.y = speed;
        }
        else if (FlxG.keys.anyPressed([UP, W]))
        {
            velocity.y = -speed;
        }
    }
}