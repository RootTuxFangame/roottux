package creatures.player;

// AnatolyStev: Adds Echo-Flixel stuff here and everywhere else it's needed for now (solid and playstate)
// also helps with adding skidding

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

using echo.FlxEcho;

enum TuxStates
{
    Small;
    Big;
    Fire;
}

class Tux extends FlxSprite
{
    // Movement
    var tuxAcceleration:Int = 1000; // not exactly a random number, but kind of is
    var deceleration:Int = 800;
    public var minJumpHeight:Int = 512;
    public var maxJumpHeight:Int = 576;
    var speed:Int = 320;
    var decelerateOnJumpRelease:Float = 0; // Set this to a higher number to make it more similar to Milestone 2.

    // Skidding
    var skid:Bool = false;
    var skidCooldown:Float = 0.0;
    
    // Health
    var canTakeDamage:Bool = true;
    var invFrames:Float = 1.0;

    // Direction (-1 = left, 1 = right)
    public var direction:Int = 1;

    // Holding Enemies
    // public var heldEnemy:Enemy = null;

    // Self-explanatory
    public var currentState:TuxStates = Small;

    // Fireball variables
    public var canShoot:Bool = false;
    public var shootCooldown:Float = 1.0; // Instead of checking the amount of fireballs, a cooldown is used instead.

    // Invincibility Powerup
    var starDuration:Float = 14.0;
    public var invincible:Bool = false;
    var stars:FlxSprite;

    // Spritesheet
    var small_image = FlxAtlasFrames.fromSparrow("assets/images/creatures/tux/small_tux.png", "assets/images/creatures/tux/small_tux.xml");

    public function new()
    {
        super();

        // Spritesheet
        frames = small_image;
        animation.addByPrefix("stand", "stand", 15, false);
        animation.addByPrefix("walk", "walk", 15, true);
        animation.addByPrefix("jump", "jump", 15, false);
        animation.addByPrefix("skid", "skid", 15, false);
        animation.addByPrefix("kick", "kick", 15, false);

        setSize(31, 31);
        offset.set(0, 5.5);

        this.add_body({x: this.x, y: this.y, max_velocity_x: speed, drag_x: deceleration, mass: 1.0, shape: {type: RECT, width: 31, height: 31}, material: {elasticity: 0.0}});

        reloadGraphics();
    }

    override public function update(elapsed:Float)
    {
        var body = FlxEcho.get_body(this);

        // x = body.x - width * 0.5; // is this needed?
        // y = body.y - height * 0.5; // is this needed?

        velocity.x = body.velocity.x;
        velocity.y = body.velocity.y;

        // Stop Tux from falling off the left side of the level
        if (body.x < 0)
        {
            body.x = 0;
        }

        if (body.y > Global.PS.map.height - height)
        {
            die();
        }

        move();
        animate();
        shootFire();

        // if (heldEnemy != null)
        // {
        //     if (FlxG.keys.justPressed.CONTROL)
        //     {
        //         throwEnemy();
        //     }
        // }

        super.update(elapsed);
    }

    function animate()
    {
        var body = FlxEcho.get_body(this);

        // These don't need to be changed for now.
        if (skid && animation.name != "skid")
        {
            animation.play("skid");
        }

        if (body.velocity.x == 0 && isTouching(FLOOR) && !skid)
        {
            animation.play("stand");
        }

        if (body.velocity.x != 0 && isTouching(FLOOR) && !isTouching(WALL) && !skid)
        {
            animation.play("walk");
        }

        if (body.velocity.y != 0 && !isTouching(FLOOR) && !skid)
        {
            animation.play("jump");
        }
    }

    function move()
    {
        var body = FlxEcho.get_body(this);

        // adding skidding is so fun! /j
        var wasSkidding = skid;

        // Speed is 0 at beginning (so Tux isn't like Sonic)
        body.acceleration.x = 0;

        // If player presses left keys, move left, if player presses right keys, move right.
        if (FlxG.keys.anyPressed([LEFT, A]))
        {
            if (body.velocity.x > 0)
            {
                body.velocity.x *= 0.99;

                if (body.velocity.x > 220 && isTouching(FLOOR) && !isTouching(WALL))
                {
                    skid = true;
                    skidCooldown = 0.2;
                }
            }

            flipX = true; // TODO: Shouldn't this be in the animate function?
            direction = -1;
            body.acceleration.x = -tuxAcceleration;
        }
        else if (FlxG.keys.anyPressed([RIGHT, D]))
        {
            if (body.velocity.x < 0)
            {
                body.velocity.x *= 0.99;

                if (body.velocity.x < -220 && isTouching(FLOOR) && !isTouching(WALL))
                {
                    skid = true;
                    skidCooldown = 0.2;
                }
            }

            flipX = false;
            direction = 1;
            body.acceleration.x = tuxAcceleration;
        }
        else
        {
            body.acceleration.x = 0;
        }

        if (skid && !wasSkidding)
        {
            FlxG.sound.play("assets/sounds/skid.wav");
        }

        // If player pressing jump keys and is on ground, jump. 
        // If player is walking at the speed of walkSpeed, jump higher than usual.
        if (FlxG.keys.anyJustPressed([SPACE, W, UP]) && isTouching(FLOOR))
        {
            if (body.velocity.x == speed || body.velocity.x == -speed)
            {
                body.velocity.y = -maxJumpHeight;
            }
            else
            {
                body.velocity.y = -minJumpHeight;
            }

            // If current state is small, play small jump sound.
            // If current state is not small, play big jump sound.
            if (currentState == Small)
            {
                FlxG.sound.play("assets/sounds/jump.wav");
            }
            else
            {
                FlxG.sound.play("assets/sounds/bigjump.wav");
            }
        }

        if (body.velocity.y < 0 && FlxG.keys.anyJustReleased([SPACE, W, UP]))
        {
            body.velocity.y -= body.velocity.y;
        }

        if (Math.abs(body.velocity.x) < 180 || !isTouching(FLOOR))
        {
            skid = false;
        }

        if (skidCooldown > 0)
        {
            skidCooldown -= FlxG.elapsed;
            skid = true;
        }
        else
        {
            skid = false;
        }
    }

    // public function holdEnemy(enemy:Enemy)
    // {
    //     // If there's already a held enemy, return.
    //     if (heldEnemy != null)
    //     {
    //         return;
    //     }

    //     // If there's no held enemy and player is pressing control, pick up enemy.
    //     if (FlxG.keys.pressed.CONTROL)
    //     {
    //         heldEnemy = enemy;
    //         enemy.pickUp(this);
    //     }
    // }

    // public function throwEnemy()
    // {
    //     // If there's no held enemy, don't do the rest of the function.
    //     if (heldEnemy == null)
    //     {
    //         return;
    //     }

    //     // Throw enemy
    //     heldEnemy.enemyThrow();
    //     heldEnemy = null;
    // }

    public function takeDamage() //  Makes Tux take damage.
    {
        var body = FlxEcho.get_body(this);

        if (canTakeDamage)
        {
            canTakeDamage = false;
            FlxTween.flicker(this, invFrames, 0.1, {type: ONESHOT});
            new FlxTimer().start(invFrames, function(_) {canTakeDamage = true;}, 1);
            FlxG.sound.play('assets/sounds/hurt.wav');
            
            if (currentState == Fire) // If current state is fire, make him go down to just being big.
            {
                currentState = Big;
                reloadGraphics();
            }
            else if (currentState == Big) // If current state is big, make him go down to just being small.
            {
                var prevBottom = body.y + body.scale_y;
                currentState = Small;
                reloadGraphics();
                body.y = prevBottom - body.scale_y;
            }
            else if (currentState == Small) // If current state is small, kill him.
            {
                die();
            }
        }
    }

    public function bigTux()
    {
        var body = FlxEcho.get_body(this);

        if (currentState == Small)
        {
            var smallHeight = body.scale_y;
            currentState = Big;
            reloadGraphics();
            body.y -= body.scale_y - smallHeight;
        }
    }

    public function fireTux()
    {
        var body = FlxEcho.get_body(this);

        if (currentState == Small)
        {
            var smallHeight = body.scale_y;
            currentState = Fire;
            reloadGraphics();
            body.y -= body.scale_y - smallHeight;
        }
        else
        {
            currentState = Fire;
            reloadGraphics();
        }
    }

    public function starTux()
    {
        var previousSong = Global.currentSong;

        FlxG.sound.play("assets/sounds/herring.wav", 1, false);
        FlxG.sound.playMusic("assets/music/salcon.ogg", 1, true);

        invincible = true;

        new FlxTimer().start(starDuration, function(_)
        {
            FlxG.sound.playMusic(previousSong, 1.0, true);
            invincible = false;
        });
    }

    function shootFire()
    {
        if (currentState != Fire)
        {
            return;
        }

        // if (FlxG.keys.justPressed.CONTROL && canShoot)
        // {
        //     var fireball:Fireball = new Fireball(x + 16, y + 16);
        //     fireball.direction = direction;
        //     Global.PS.items.add(fireball);
        //     FlxG.sound.play("assets/sounds/shoot.wav");

        //     canShoot = false;
        //     new FlxTimer().start(shootCooldown, function(_) canShoot = true);
        // }
    }

    public function die()
    {
        currentState = Small;
        Global.tuxState = Small;
        canTakeDamage = false;
        FlxG.resetState();
    }

    public function reloadGraphics()
    {
        var body = FlxEcho.get_body(this);
        animation.reset();

        switch(currentState)
        {
            case Small:
                var fixedMaybeOne = FlxAtlasFrames.fromSparrow("assets/images/creatures/tux/small_tux.png", "assets/images/creatures/tux/small_tux.xml");
                frames = fixedMaybeOne;

                animation.addByPrefix('stand', 'stand', 10, false);
                animation.addByPrefix('walk', 'walk', 10, true);
                animation.addByPrefix('jump', 'jump', 10, false);
                animation.addByPrefix("skid", "skid", 15, false);
                animation.addByPrefix("kick", "kick", 15, false);
                animation.play('stand');

                setSize(31, 31);
                offset.set(0, 5.5);

                body.scale_x = width;
                body.scale_y = height;

            case Big:
                var fixedMaybeTwo = FlxAtlasFrames.fromSparrow("assets/images/creatures/tux/big_tux.png", "assets/images/creatures/tux/big_tux.xml");
                frames = fixedMaybeTwo;
                animation.addByPrefix('stand', 'stand', 10, false);
                animation.addByPrefix('walk', 'walk', 10, true);
                animation.addByPrefix('jump', 'jump', 10, false);
                animation.addByPrefix("skid", "skid", 15, false);
                animation.addByPrefix("kick", "kick", 15, false);
                animation.addByPrefix('duck', 'duck', 10, false);
                animation.play('stand');

                setSize(30, 63);
                offset.set(10, 4);
                
                body.scale_x = width;
                body.scale_y = height;

            case Fire:
                var fixedMaybeThree = FlxAtlasFrames.fromSparrow("assets/images/creatures/tux/fire_tux.png", "assets/images/creatures/tux/fire_tux.xml");
                frames = fixedMaybeThree;
                animation.addByPrefix('stand', 'stand', 10, false);
                animation.addByPrefix('walk', 'walk', 10, true);
                animation.addByPrefix('jump', 'jump', 10, false);
                animation.addByPrefix("skid", "skid", 15, false);
                animation.addByPrefix("kick", "kick", 15, false);
                animation.addByPrefix('duck', 'duck', 10, false);
                animation.play('stand');
                setSize(30, 63);
                offset.set(10, 4);

                body.scale_x = width;
                body.scale_y = height;
        }
    }
}