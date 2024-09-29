package states.stages;

import states.stages.objects.*;
import objects.Character;

class Hank extends BaseStage
{
    var hankCity:BGSprite;
    var hankDwayneLeft:BGSprite;
    var hankDwayneRight:BGSprite;
    var hankFloor:BGSprite;
    var hankWindows:BGSprite;

    override function create() { 
        if(!ClientPrefs.data.lowQuality) {
			var bg:BGSprite = new BGSprite('stageImages/Accelerant/sky', -250, -350, 0.1, 0.1);
			add(bg);
		}

        var city:BGSprite = new BGSprite('stageImages/Accelerant/city', -300, -280, 0.1, 0.1);
		city.setGraphicSize(Std.int(city.width * 0.9));
		city.updateHitbox();
		add(city);

        var windows:BGSprite = new BGSprite ('stageImages/Accelerant/windows', -300, -280, 0.1, 0.1);
        windows.setGraphicSize(Std.int(windows.width * 0.9));
        windows.updateHitbox();
        add(windows);
        
        var dwayneLeft:BGSprite = new BGSprite ('stageImages/Accelerant/dwayneLeft', -285, -200, 0.4, 0.5);
        dwayneLeft.setGraphicSize(Std.int(dwayneLeft.width * 0.85));
        dwayneLeft.updateHitbox();
        add(dwayneLeft);

        var dwayneRight:BGSprite = new BGSprite ('stageImages/Accelerant/dwayneRight', 1290, -200, 0.4, 0.5);
        dwayneRight.setGraphicSize(Std.int(dwayneRight.width * 0.85));
        dwayneRight.updateHitbox();
        add(dwayneRight);

        var floor:BGSprite = new BGSprite ('stageImages/Accelerant/floor', -400, -350, 0.9, 0.9);
        floor.setGraphicSize(Std.int(floor.width * 1.15));
        floor.updateHitbox();
        add(floor);
    }
}
