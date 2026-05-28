package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class HUD extends FlxState
{
    var coinText:FlxText;

    public function new()
    {
        super();

        coinText = new FlxText(0, 4, FlxG.width, "Coins: " + Global.coins, 18);
        coinText.setFormat("assets/fonts/SuperTux-Medium.ttf", 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        coinText.scrollFactor.set();
        coinText.borderSize = 1.25;

        add(coinText);
    }

    override public function update(elapsed:Float)
    {
        coinText.text = "Coins: " + (Global.coins);
        super.update(elapsed);
    }
}