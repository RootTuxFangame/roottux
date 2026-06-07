package;

import creatures.player.Tux.TuxStates;
import flixel.util.FlxSave;
import lime.utils.Assets;
import states.PlayState;
import worldmap.WorldmapState;

class Global
{
    public static var coins:Int = 0;
    public static var tuxState:TuxStates = Small;

    public static var PS:PlayState;
    public static var WMS:WorldmapState;

    public static var currentLevel:String;
    public static var levelName:String;
    public static var levelCreator:String;
    public static var dotLevelName:String = "";
    
    public static var checkpointReached:Bool = false;

    public static var worldmaps:Array<String> = [];

    public static var currentWorldmap:Int = 0;
    public static var worldmapName:String;
    public static var currentSection:String;
    public static var tuxWorldmapX:Float = 0.0;
    public static var tuxWorldmapY:Float = 0.0;

    public static var completedLevels:Array<String> = [];
    public static var completedSections:Array<String> = [];

    public static var currentSong:String;

    public static var saveVersion:Int = 1;
    public static var saveFile:FlxSave = new FlxSave();
    public static var saveName = "RootTuxSave";

    public static function initSave()
    {
        saveFile.bind(saveName);
    }

    public static function saveProgress()
    {
        if (!saveFile.bind(saveName))
        {
            return;
        }

        if (saveFile.data != null)
        {
            saveFile.data.saveVersion = saveVersion;
            saveFile.data.completedLevels = completedLevels;
            saveFile.data.currentWorldmap = currentWorldmap;
            saveFile.data.tuxWorldmapX = tuxWorldmapX;
            saveFile.data.tuxWorldmapY = tuxWorldmapY;
            saveFile.data.coins = coins;
            saveFile.data.tuxState = tuxState;

            saveFile.flush();
        }
    }

    public static function loadProgress()
    {
        if (saveFile.data != null)
        {
            if (Reflect.hasField(saveFile.data, "completedLevels"))
            {
                completedLevels = saveFile.data.completedLevels;
            }
            
            if (Reflect.hasField(saveFile.data, "currentWorldmap"))
            {
                currentWorldmap = saveFile.data.currentWorldmap;
            }

            if (Reflect.hasField(saveFile.data, "tuxWorldmapX"))
            {
                tuxWorldmapX = saveFile.data.tuxWorldmapX;
            }

            if (Reflect.hasField(saveFile.data, "tuxWorldmapY"))
            {
                tuxWorldmapY = saveFile.data.tuxWorldmapY;
            }

            if (Reflect.hasField(saveFile.data, "coins"))
            {
                coins = saveFile.data.coins;
            }

            if (Reflect.hasField(saveFile.data, "tuxState"))
            {
                tuxState = saveFile.data.tuxState;
            }

            if (!Reflect.hasField(saveFile.data, "saveVersion"))
            {
                saveFile.data.saveVersion = saveVersion;
            }
        }
    }

    public static function eraseSave()
    {
        saveFile.erase();
        saveFile.flush();
        saveFile.bind(saveName);
        Global.completedLevels = [];
        Global.coins = 0;
        Global.currentWorldmap = 0;
    }

    public static function loadWorldmaps()
    {
        worldmaps = Assets.getText("assets/data/worldmaps.txt").split("\n").map(StringTools.trim).filter(function(l) return l != "");
    }
}