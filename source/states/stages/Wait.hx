package states.stages;

import states.stages.objects.*;

class Wait extends BaseStage 
{
    override function create()
        {

        var blackScreen:FlxSprite = new FlxSprite(-900, -500).makeGraphic(Std.int(FlxG.width * 10), Std.int(FlxG.height * 10), FlxColor.WHITE);
		blackScreen.scrollFactor.set();
		add(blackScreen);
    }
}