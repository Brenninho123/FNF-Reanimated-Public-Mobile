package states.stages.objects;

import flixel.FlxObject;
import flixel.util.FlxAxes;
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxSprite;

class ABot extends FlxTypedSpriteGroup<FlxSprite>
{

    var system:FlxAnimate;
	public var eyes:FlxAnimate;
	var eyeBack:FlxSprite;
	var bg:FlxSprite;
	var visualizer:ABotVisualizer;

	//Muchísimas gracias a SB Engine porque lo de los ojos me estaba comiendo la cabeza aaa

	public function new(x:Float, y:Float) {
		super(x, y);

		var antialias:Bool = ClientPrefs.data.antialiasing;

		bg = new FlxSprite(147, 31).loadGraphic(Paths.image("abot/stereoBG"));
		bg.antialiasing = true;

		eyeBack = new FlxSprite(55, 240).makeGraphic(1, 1, 0xFFFFFFFF);
		eyeBack.scale.set(120, 50);
		eyeBack.updateHitbox();

		eyes = new FlxAnimate(60, 240);
		Paths.loadAnimateAtlas(eyes, 'abot/systemEyes');
		eyes.anim.addBySymbolIndices('lookleft', 'a bot eyes lookin', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17], 24, false);
		eyes.anim.addBySymbolIndices('lookright', 'a bot eyes lookin', [18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35], 24, false);
		eyes.anim.play('lookright', true);
		eyes.anim.curFrame = eyes.anim.length - 1;

		system = new FlxAnimate(0,0);
		Paths.loadAnimateAtlas(system, 'abot/abotSystem');
		system.anim.addBySymbol('bop', 'Abot System', 24, false);
		system.anim.play('bop', true);
		system.anim.curFrame = system.anim.length - 1;
		system.antialiasing = antialias;

		visualizer = new ABotVisualizer(null);
		visualizer.setPosition(203, 88);

		add(bg);
		add(eyeBack);
		add(eyes);
		add(visualizer);
		add(system);

	}

	public function setAudioSource(source:FlxSound):Void{
		visualizer.snd = source;
	}

	public function startVisualizer():Void{
		if(visualizer.snd != null){
			visualizer.initAnalyzer();
		}
	}

	public function bop():Void{
		system.anim.play("bop", true);
	}

	var lookingAtRight:Bool = true;
	public function lookLeft()
	{
		if(lookingAtRight) eyes.anim.play('lookleft', true);
		lookingAtRight = false;
	}
	public function lookRight()
	{
		if(!lookingAtRight) eyes.anim.play('lookright', true);
		lookingAtRight = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

}