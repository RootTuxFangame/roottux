package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import worldmap.WorldmapState;

class IntroState extends FlxState
{
    var introText:FlxText;

    var speed = 20;
    var increaseOrDecreaseSpeed = 10;

    override public function create()
    {
        super.create();

        var bg = new FlxSprite();
        bg.loadGraphic("assets/images/background/arctis.jpg", false);
        add(bg);
        
        introText = new FlxText(-65, 480, 0, "
        Penny gets captured!
        
        Tux and Penny were out having a nice picnic on the
        ice fields of Icy Island. Suddenly, a creature
        jumped from behind an ice bush, there was a flash,
        and Tux became unconscious!
        
        When Tux woke up, he found that Penny was missing!
        Where she lay before now lies a letter,

        The letter said:
        Tux, my arch enemy! I have captured your beautiful
        Penny and have taken her to my fortress. The path
        to my fortress is literred with my minions. Give
        up on the thought of trying to get her back, you
        haven't got a chance! -Nolok

        Tux looked and saw Nolok's fortress in the distance.
        Determined to save his beloved Penny, he began his 
        journey.

        
        
        Press SPACE to go to the worldmap.", 18);
        introText.setFormat("assets/fonts/SuperTux-Medium.ttf", 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        introText.borderSize = 1.25;
        introText.moves = true;
        introText.velocity.y = -speed;
        add(introText);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.SPACE)
        {
            FlxG.switchState(WorldmapState.new); // Switch State
        }
        
        if (FlxG.keys.justPressed.DOWN)
        {
            introText.velocity.y -= increaseOrDecreaseSpeed;
        }
        else if (FlxG.keys.justPressed.UP)
        {
            introText.velocity.y += increaseOrDecreaseSpeed;
        }
    }
}