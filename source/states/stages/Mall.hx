package states.stages;

import states.stages.objects.*;
import cutscenes.CutsceneHandler;
import objects.Character;

class Mall extends BaseStage
{
	var upperBoppers:BGSprite;
	var bottomBoppers:MallCrowd;
	var tree:BGSprite;
	var santa:BGSprite;
	var snowfallin:BGSprite;
	var santaDead:Character;
	var parentsCutscene:Character;
	var cutsceneHandler:CutsceneHandler;

	override function create()
	{
		var bg:BGSprite = new BGSprite('christmas/bgWalls', -1150, -850, 0.2, 0.2);
		bg.setGraphicSize(Std.int(bg.width * 1.8));
		bg.updateHitbox();
		add(bg);

		var ceiling:BGSprite = new BGSprite('christmas/Ceiling', -1150, -850, 0.2, 0.2);
		ceiling.setGraphicSize(Std.int(ceiling.width * 1.8));
		ceiling.updateHitbox();
		add(ceiling);

		if(!ClientPrefs.data.lowQuality) {
			upperBoppers = new BGSprite('christmas/upperBop', -600, -320, 0.33, 0.33, ['upperBop0']);
			upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 1.05));
			upperBoppers.updateHitbox();
			add(upperBoppers);

			var bgEscalator:BGSprite = new BGSprite('christmas/bgEscalator', -1100, -400, 0.3, 0.3);
			bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 1.9));
			bgEscalator.updateHitbox();
			add(bgEscalator);

			snowfallin = new BGSprite('christmas/snowfallin_bg', -1120, -650, 0.9, 0.9, ['snowfallin0'], true);
			snowfallin.setGraphicSize(Std.int(snowfallin.width * 2.6));
			snowfallin.updateHitbox();
	
		}

		var blanck:BGSprite = new BGSprite('christmas/white', -1250, -350, 0.9, 0.9);
		//blanck.blend = ADD;
		blanck.setGraphicSize(Std.int(blanck.width * 1.8));
		blanck.updateHitbox();
		add(blanck);

		var fgSnow:BGSprite = new BGSprite('christmas/fgSnow', -1500, 440, 0.9, 0.9);
		fgSnow.setGraphicSize(Std.int(fgSnow.width * 2));
		fgSnow.updateHitbox();
		add(fgSnow);

		tree = new BGSprite('christmas/christmasTree', 370, -650, 0.9, 0.9, ['Christmas Tree']);
		tree.scale.set(1.3, 1.3);
		add(tree);

		bottomBoppers = new MallCrowd(-400, 100);
		add(bottomBoppers);

		parentsCutscene = new Character(dadGroup.x, dadGroup.y, "parents-christmas-cutscene", false);
		parentsCutscene.x += parentsCutscene.positionArray[0];
		parentsCutscene.y += parentsCutscene.positionArray[1];
		parentsCutscene.visible = false;
		add(parentsCutscene);

		santa = new BGSprite('christmas/santa', -840, 150, 1, 1, ['santa idle in fear']);
		Paths.sound('Lights_Shut_off');

		santaDead = new Character(santa.x,santa.y, "santa", false);
		santaDead.x += santaDead.positionArray[0];
		santaDead.y += santaDead.positionArray[1];
		santaDead.visible = false;
		add(santaDead);
		setDefaultGF('gf-christmas');

		if (!isStoryMode)
			if (PlayState.SONG.song.toLowerCase() == "eggnog")
			{
				setEndCallback(eggnogErectCutscene);
			}
		if(isStoryMode && !seenCutscene)
			setEndCallback(eggnogEndCutscene);
	}

	override function createPost()
		{
			add(santa);
			add(snowfallin);
		}

	override function countdownTick(count:Countdown, num:Int) everyoneDance();
	override function beatHit() everyoneDance();

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "Hey!":
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						return;
				}
				bottomBoppers.animation.play('hey', true);
				bottomBoppers.heyTimer = flValue2;
		}
	}

	function everyoneDance()
	{
		if(!ClientPrefs.data.lowQuality)
			bottomBoppers.dance(true);
			upperBoppers.dance(true);
			tree.dance(true);
			santa.dance(true);
	}

	function eggnogEndCutscene()
	{
		if(PlayState.storyPlaylist[1] == null)
		{
			endSong();
			return;
		}

		var nextSong:String = Paths.formatToSongPath(PlayState.storyPlaylist[1]);
		if(nextSong == 'winter-horrorland')
		{
			FlxG.sound.play(Paths.sound('Lights_Shut_off'));

			var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
				-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			blackShit.scrollFactor.set();
			add(blackShit);
			camHUD.visible = false;

			inCutscene = true;
			canPause = false;

			new FlxTimer().start(1.5, function(tmr:FlxTimer) {
				endSong();
			});
		}
		else endSong();
	}

		function prepareEggnogCutscene()
	{
		cutsceneHandler = new CutsceneHandler();

		santa.visible = false;
		dad.visible = false;
		parentsCutscene.visible = true;
		santaDead.visible = true;

		game.inCutscene = true;
		game.isCameraOnForcedPos = true;

		Paths.sound('santa_emotion');

		FlxTween.tween(camHUD, {alpha: 0}, 1,  {ease: FlxEase.sineInOut});

		cutsceneHandler.finishCallback = function()
		{
			game.inCutscene = false;
			camHUD.fade(0xFF000000, 0.5, true, null, true);
			new FlxTimer().start(0.5, function(tmr)
			{
				endSong();
			});
		}
	}

	function eggnogErectCutscene()
	{
		prepareEggnogCutscene();
		cutsceneHandler.endTime = 16;

		canPause = false;

		parentsCutscene.playAnim("PlayCutscene");
		santaDead.playAnim("PlayAnimation");

		game.tweenCameraToPosition(santaDead.x + 300, santaDead.y, 2.8, FlxEase.expoOut);
		game.tweenCameraZoom(0.73, 2, true, FlxEase.quadInOut);
		FlxG.sound.play(Paths.sound('santa_emotion'));

		cutsceneHandler.timer(2.8, function()
		{
			game.tweenCameraToPosition(santaDead.x + 150, santaDead.y, 9, FlxEase.quartInOut);
			game.tweenCameraZoom(0.79, 9, true, FlxEase.quadInOut);
		});

		cutsceneHandler.timer(11.375, function()
		{
			FlxG.sound.play(Paths.sound('santa_shot_n_falls'));
		});

		
		cutsceneHandler.timer(12.83, function()
		{
			camGame.shake(0.005, 0.2);
			game.tweenCameraToPosition(santaDead.x + 160, santaDead.y + 80, 5, FlxEase.expoOut);
		});

		cutsceneHandler.timer(15, function()
		{
			camHUD.fade(0xFF000000, 1, false, null, true);
		});

	}
}