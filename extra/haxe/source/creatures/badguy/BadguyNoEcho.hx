package creatures.badguy;

/* This is the worst way I could've chose to fix the lag issue. But it works better than even PepperTux-Haxe's only-flixel physics stuff. Things are looking good!
   ...and cursed.
   -Vaesea 30/05/2026 */

/* o yea i learned how to do comments that are multiple lines in haxeflixel!!!
   it's the same as c++!!! */

import flixel.util.FlxTimer;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.sound.FlxSound;
import creatures.player.Tux;
import flixel.FlxSprite;

using echo.FlxEcho;

enum BadguyStates
{
    Alive;
    Dead;
}

enum IceblockStates2
{
    Normal;
    Squished;
    MovingSquished;
    Held;
}

class BadguyNoEcho extends FlxSprite
{
    // Badguy dying from falling and corpse timer for when it's squished
    var fallJump:Int = 128;
    var dieFall:Bool = false;
    var corpseTimer:Float = 2.0;

    var gravityWhenDead:Int = 1000;

    // Current state (Alive / Dead), should be set to Alive to avoid issues.
    var currentState:BadguyStates = Alive;

    // Iceblock
    public var canBeHeld:Bool = false;
    public var currentIceblockState:IceblockStates2 = Normal;
    public var held:Tux = null;
    var waitToCollide:Float = 0;
    var damageOthers:Bool = false;
    
    // Fireball
    var canFireballDamage:Bool = true;

    // Movement
    var walkSpeed:Int = 80;
    var jumpHeight:Int = 128;
    var appearWhenLevelLoads:Bool = false;
    public var direction:Int = -1;
    var appeared:Bool = false;
    var gravity = 1000;

    // Sound
    var fallSound:FlxSound;

    public function new(x:Float, y:Float)
    {
        super(x, y);
        immovable = false;
        
        fallSound = FlxG.sound.load("assets/sounds/fall.ogg", 1, false);
        fallSound.proximity(x, y, FlxG.camera.target, 150, true);
    }

    override public function update(elapsed:Float)
    {
        if (waitToCollide > 0)
        {
            waitToCollide -= elapsed;
        }

        if (!appearWhenLevelLoads)
        {
            if (isOnScreen())
            {
                appeared = true;
            }
            
            if (appeared && alive)
            {
                move();

                if (justTouched(WALL))
                {
                    flipDirection();
                }
            }
        }
        else
        {
            exists = true;
            appeared = true;
            move();
        }

        if (canBeHeld)
        {
            if (currentIceblockState == Held && held != null)
            {
                if (held.flipX == true)
                {
                    x = held.x - 8;
                }
                else if (held.flipX == false)
                {
                    x = held.x + 11;
                }

                y = held.y;
                flipX = !held.flipX;
            }

            if (justTouched(WALL) && isOnScreen() && currentIceblockState == MovingSquished)
            {
                FlxG.sound.play("assets/sounds/ricochet.wav", 1.0, false);
            }
        }

        super.update(elapsed);
    }
    
    function flipDirection() 
    {
        flipX = !flipX;
        direction = -direction;
    }

    // Badguys override this.
    function move() 
    {
    }

    public function interact(tux:Tux)
    {
        checkIfStar(tux);

        var tuxStomp = (tux.velocity.y > 0 && tux.y + tux.height < y + 10); // i forgot what this does

        if (!alive || waitToCollide > 0)
        {
            return;
        }

        if (currentIceblockState == MovingSquished)
        {
            damageOthers = true;
        }

        FlxObject.separateY(tux, this);

        if (tuxStomp && !tux.invincible)
        {
            if (FlxG.keys.pressed.SPACE)
            {
                tux.get_body().velocity.y = -tux.minJumpHeight;
            }
            else
            {
                tux.get_body().velocity.y = -tux.minJumpHeight / 2;
            }

            if (!canBeHeld)
            {
                kill();
            }
            else
            {
                waitToCollide = 0.25;

                if (currentIceblockState == MovingSquished)
                {
                    currentIceblockState = Squished;
                    animation.play("flat");
                    velocity.x = 0;
                }
                else if (currentIceblockState == Squished)
                {
                    direction = tux.direction;
                    flipX = !tux.flipX;
                    currentIceblockState = MovingSquished;
                    damageOthers = true;
                }
                else
                {
                    animation.play("flat");
                    currentIceblockState = Squished;
                    velocity.x = 0;
                }
            }
            
            return;
        }

        // Not fully added yet
        // if (canBeHeld && currentIceblockState == Squished)
        // {
        //     if (!isTouching(UP) && FlxG.keys.pressed.CONTROL && tux.heldEnemy == null)
        //     {
        //         tux.holdIceblock(this);
        //         return;
        //     }

        //     if (!tuxStomp)
        //     {
        //         direction = tux.direction;
        //         flipX = !tux.flipX;
        //         currentIceblockState = MovingSquished;
        //         damageOthers = true;
        //         FlxG.sound.play("assets/sounds/kick.wav");
        //         waitToCollide = 0.25;
        //         return;
        //     }
        // }

        // Shouldn't get this far unless Tux should actaully be damaged.
        tux.takeDamage();
    }

    override public function kill()
    {
        currentState = Dead;

        if (!dieFall)
        {
            FlxG.sound.play("assets/sounds/squish.wav");
            alive = false;
            velocity.x = 0;
            acceleration.x = 0;
            acceleration.y = gravityWhenDead; // doesn't work and would just be a HACK anyways
            animation.play("squished");
        
            new FlxTimer().start(corpseTimer, function(_)
            {
                exists = false;
                visible = false;
            }, 1);
        }
        else
        {
            fallSound.setPosition(x + width / 2, y + height);
            fallSound.play();
            flipY = true;
            acceleration.x = 0;
        }
    }

    function checkIfStar(tux:Tux)
    {
        if (tux.invincible)
        {
            killFall();
        }
    }

    public function killFall()
    {
        dieFall = true;
        kill();
    }

    public function collideOtherBadguy(otherBadguy:BadguyNoEcho)
    {
        if (otherBadguy.damageOthers)
        {
            killFall();
        }
    }

    // public function collideFireball(fireball:Fireball)
    // {
    //     fireball.kill();

    //     if (canFireballDamage)
    //     {
    //         killFall();
    //     }
    // }

    public function pickUp(tux:Tux)
    {
        if (canBeHeld)
        {
            if (currentIceblockState != Squished || held != null)
            {
                return;
            }

            currentIceblockState = Held;
            held = tux;
            solid = false;
            velocity.x = 0;
            velocity.y = 0;
            animation.play("flat");
        }
    }

    public function iceblockThrow() // originally written by anatolystev, i think?
    {
        if (canBeHeld)
        {
            if (currentIceblockState != Held || held == null)
            {
                return;
            }

            currentIceblockState = MovingSquished;
            direction = held.direction;
            flipX = !held.flipX;
            solid = true;
            damageOthers = true;
            held = null;
            waitToCollide = 0.25;
            FlxG.sound.play("assets/sounds/kick.wav");
        }
    }
}