package creatures.badguy;

// there are a few issues with held enemies because i'm not using the 
// echo-flixel functions and i am instead using stuff like solid = false
// those don't matter right now though :3
// -Vaesea

// It's extremely laggy and slow, but it'll have to do for now.
// -Vaesea

import flixel.util.FlxTimer;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.sound.FlxSound;
import creatures.player.Tux;
import flixel.FlxSprite;

using echo.FlxEcho;

enum EnemyStates
{
    Alive;
    Dead;
}

enum IceblockStates
{
    Normal;
    Squished;
    MovingSquished;
    Held;
}

class Badguy extends FlxSprite
{
    // Badguy dying from falling and corpse timer for when it's squished
    var fallJump:Int = 128;
    var dieFall:Bool = false;
    var corpseTimer:Float = 2.0;

    var gravityWhenDead:Int = 1000;

    // Current state (Alive / Dead), should be set to Alive to avoid issues.
    var currentState:EnemyStates = Alive;

    // Iceblock
    public var canBeHeld:Bool = false;
    public var currentIceblockState:IceblockStates = Normal;
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
        var body = this.get_body();

        if (body == null)
        {
            return;
        }
        
        // body.x = x + width * 0.5;
        // body.y = y + height * 0.5

        if (!appearWhenLevelLoads && !isOnScreen())
        {
            body.active = false;
        }
        else if (!appearWhenLevelLoads && isOnScreen())
        {
            body.active = true;
        }

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
                    body.x = held.get_body().x - 8;
                }
                else if (held.flipX == false)
                {
                    body.x = held.get_body().x + 11;
                }

                y = held.get_body().y;
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
        var tuxBody = tux.get_body();
        var thisBody = this.get_body();

        checkIfStar(tux);

        var tuxStomp = (tuxBody.velocity.y > 0 && tux.y + tuxBody.scale_y < y + 10); // i forgot what this does

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
                tuxBody.velocity.y = -tux.minJumpHeight;
            }
            else
            {
                tuxBody.velocity.y = -tux.minJumpHeight / 2;
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
                    thisBody.velocity.x = 0;
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
                    thisBody.velocity.x = 0;
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
        var body = this.get_body();

        currentState = Dead;

        if (!dieFall)
        {
            FlxG.sound.play("assets/sounds/squish.wav");
            alive = false;
            body.velocity.x = 0;
            body.acceleration.x = 0;
            this.remove_object();
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
            body.acceleration.x = 0;
            this.remove_object();
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

    public function collideOtherBadguy(otherBadguy:Badguy)
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
        var body = this.get_body();

        if (canBeHeld)
        {
            if (currentIceblockState != Squished || held != null)
            {
                return;
            }

            currentIceblockState = Held;
            held = tux;
            solid = false;
            body.velocity.x = 0;
            body.velocity.y = 0;
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