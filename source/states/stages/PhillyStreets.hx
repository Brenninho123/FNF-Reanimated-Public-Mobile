package states.stages;

import flixel.FlxBasic;
import states.stages.objects.*;
import objects.Character;
import flixel.addons.display.FlxBackdrop;
import cutscenes.CutsceneHandler;
import objects.Character;
import backend.MathUtil;
import objects.Note;
import flash.display.BlendMode;
import torchsthings.shaders.*;
import torchsfunctions.functions.ShaderUtils;
import torchsthings.objects.ReflectedChar;
import openfl.filters.ShaderFilter;
import substates.GameOverSubstate;
import flixel.addons.display.FlxTiledSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;

/*enum NeneState
{
	STATE_DEFAULT;
	STATE_PRE_RAISE;
	STATE_RAISE;
	STATE_READY;
	STATE_LOWER;
}
*/

class PhillyStreets extends BaseStage
{
	final MIN_BLINK_DELAY:Int = 3;
	final MAX_BLINK_DELAY:Int = 7;
	final VULTURE_THRESHOLD:Float = 0.5;
	var blinkCountdown:Int = 3;

    //Stage Objects
	var scrollingSky:FlxTiledSprite;
    var phillySpray:BGSprite;
    var skyline:BGSprite;
    var foregroundcity:BGSprite;
    var highwaylight:BGSprite;
    var construction:BGSprite;
    var smog:BGSprite;
    var highway:BGSprite;
    var foreground:BGSprite;
    var puddle:BGSprite;
	var phillyTrafficLightmap:BGSprite;

    //Cars And Traffic Lights
    var phillyTraffic:FlxSprite;
	var phillyCars:FlxSprite;
	var phillyCarsBack:FlxSprite;
	var lastChange:Int = 0;
	var changeInterval:Int = 8; // make sure it doesnt change until AT LEAST this many beats
	var carWaiting:Bool = false; // if the car is waiting at the lights and is ready to go on green
	var carInterruptable:Bool = true; // if the car can be reset
	var car2Interruptable:Bool = true;
    var lightsStop:Bool = false; // state of the traffic lights

    //Shader
	var rain:Rain;
	var rainFilter:ShaderFilter;
	var useShader:Bool = false;
    var rainTimeScale:Float = 1.0;
	var rainScaler:Float = 0.55;

    //Cutscene Bools
    var inCutsceneDarnell:Bool = false;
	var seenDarnellCutscene:Bool = true;

    //Cutscene objects
    var cutsceneHandler:CutsceneHandler;
    var blackScreen:FlxSprite;
    var picoIntro1:Character;
	var picoIntro2:Character;

    //Cutscene Values
    var dadPos:Array<Float>;
    var picoPos:Array<Float>;

    //Sounds	
    var cutsceneSnd:FlxSound = new FlxSound().loadEmbedded(Paths.sound('darnellCanCutscene'));

    //Nene and Speaker
    //var abot:ABot;
	//var abotLookDir:Bool = false;	
    var knifeRaised:Bool = false;
    var blinkTime:Float = 0;
    final BLINK_MIN:Float = 1;
    final BLINK_MAX:Float = 3;

    //Notes And Events
	var didReload:Bool = false;
    var spraycan:SpraycanAtlasSprite;
	var picoFade:FlxSprite;
    var darkenable:Array<FlxSprite> = [];
    var casingFrames:FlxAtlasFrames;
    var casingGroup:FlxSpriteGroup;

    override function create() {

		if (ClientPrefs.data.shaders) rain = new Rain();
        //Game Over
        var _song = PlayState.SONG;
		var startingSong = game.startingSong;
		if(_song.gameOverSound == null || _song.gameOverSound.trim().length < 1) GameOverSubstate.deathSoundName = 'pico_loss_sfx';
		if(_song.gameOverLoop == null || _song.gameOverLoop.trim().length < 1) GameOverSubstate.loopSoundName = 'GameoverPico';
		if(_song.gameOverEnd == null || _song.gameOverEnd.trim().length < 1) GameOverSubstate.endSoundName = 'gameOverEnd-pico';
		if(_song.gameOverChar == null || _song.gameOverChar.trim().length < 1) GameOverSubstate.characterName = 'pico-dead';
		setDefaultGF('nene');

        //Adding Stage Objects

		var skyImage = Paths.image('phillyStreets/phillySkybox');
		scrollingSky = new FlxTiledSprite(skyImage, skyImage.width + 400, skyImage.height, true, false);
		scrollingSky.antialiasing = ClientPrefs.data.antialiasing;
		scrollingSky.setPosition(-650, -375);
		scrollingSky.scrollFactor.set(0.1, 0.1);
		scrollingSky.scale.set(0.65, 0.65);
		addAndDark(scrollingSky);

        skyline = new BGSprite('phillyStreets/phillySkyline', -545, -273, 0.2, 0.2);
        skyline.setGraphicSize(Std.int(skyline.width * 1));
		skyline.updateHitbox();
		addAndDark(skyline);

        foregroundcity = new BGSprite('phillyStreets/phillyForegroundCity', 625, 94, 0.3, 0.3);
        foregroundcity.setGraphicSize(Std.int(foregroundcity.width * 1));
		foregroundcity.updateHitbox();
		addAndDark(foregroundcity);

        highwaylight = new BGSprite('phillyStreets/phillyHighwayLights', 284, 305, 1.0, 1.0);
        highwaylight.setGraphicSize(Std.int(highwaylight.width * 1));
		highwaylight.updateHitbox();
		addAndDark(highwaylight);

        construction  = new BGSprite('phillyStreets/phillyConstruction', 1800, 364, 0.7, 1.0);
        construction.setGraphicSize(Std.int(construction.width * 1));
		construction.updateHitbox();
		addAndDark(construction);

        var smog = new BGSprite('phillyStreets/phillySmog',  -6, 245, 1.0, 1.0);
        smog.setGraphicSize(Std.int(smog.width * 1));
		smog.updateHitbox();
		addAndDark(smog);

        highway = new BGSprite('phillyStreets/phillyHighway', 139, 209, 1.0, 1.0);
        highway.setGraphicSize(Std.int(highway.width * 1));
		highway.updateHitbox();
		addAndDark(highway);

		var degradado:FlxSprite = new FlxSprite(284, 305).loadGraphic(Paths.image('phillyStreets/phillyHighwayLights_lightmap'));
		degradado.antialiasing = ClientPrefs.data.antialiasing;
		degradado.blend = ADD;
		degradado.scrollFactor.set(1.0, 1.0);
		degradado.updateHitbox();
		//degradado.screenCenter();
		addAndDark(degradado);

		phillyCarsBack = new FlxSprite(1748, 818);
		phillyCarsBack.frames = Paths.getSparrowAtlas("phillyStreets/phillyCars");
		phillyCarsBack.scrollFactor.set(0.9, 1);
		phillyCarsBack.antialiasing = true;
		phillyCarsBack.flipX = true;
		phillyCarsBack.animation.addByPrefix("car1", "car1", 0, false);
		phillyCarsBack.animation.addByPrefix("car2", "car2", 0, false);
		phillyCarsBack.animation.addByPrefix("car3", "car3", 0, false);
		phillyCarsBack.animation.addByPrefix("car4", "car4", 0, false);
		addAndDark(phillyCarsBack);

        phillyCars = new FlxSprite(1748, 818);
		phillyCars.frames = Paths.getSparrowAtlas("phillyStreets/phillyCars");
		phillyCars.scrollFactor.set(0.9, 1);
		phillyCars.antialiasing = true;
		phillyCars.animation.addByPrefix("car1", "car1", 0, false);
		phillyCars.animation.addByPrefix("car2", "car2", 0, false);
		phillyCars.animation.addByPrefix("car3", "car3", 0, false);
		phillyCars.animation.addByPrefix("car4", "car4", 0, false);
		addAndDark(phillyCars);

        phillyTraffic = new FlxSprite(1840, 608);
		phillyTraffic.frames = Paths.getSparrowAtlas("phillyStreets/phillyTraffic");
		phillyTraffic.scrollFactor.set(0.9, 1);
		phillyTraffic.antialiasing = true;
		phillyTraffic.animation.addByPrefix("togreen", "redtogreen", 24, false);
		phillyTraffic.animation.addByPrefix("tored", "greentored", 24, false);
		addAndDark(phillyTraffic);

        phillyTrafficLightmap = new BGSprite('phillyStreets/phillyTraffic_lightmap', 1840, 608, 0.9, 1.0, "add");
		phillyTrafficLightmap.setGraphicSize(Std.int(phillyTrafficLightmap.width * 1));
		phillyTrafficLightmap.updateHitbox();
		addAndDark(phillyTrafficLightmap);
        
        var foreground = new BGSprite('phillyStreets/phillyForeground', 88, 317, 1.0, 1.0);
        foreground.setGraphicSize(Std.int(foreground.width * 1));
		foreground.updateHitbox();
		addAndDark(foreground);

        phillySpray = new BGSprite('phillyStreets/SpraycanPile', 920, 1045, 1, 1);
		phillySpray.setGraphicSize(Std.int(phillySpray.width * 1));
		phillySpray.updateHitbox();

        spraycan = new SpraycanAtlasSprite(phillySpray.x + 530, phillySpray.y - 240);

        casingFrames = Paths.getSparrowAtlas('PicoBullet'); //precache
		casingGroup = new FlxSpriteGroup();

        //Adding Speaker
        /*abot = new ABot(1100, 740);
		add(abot);
		*/

        //Adding picoFade
        picoFade = new FlxSprite();
		picoFade.antialiasing = ClientPrefs.data.antialiasing;
		picoFade.alpha = 0;
		addAndDark(picoFade);

        //Setting Up Shader 
		if(ClientPrefs.data.shaders)
		{
			switch(PlayState.SONG.song.toLowerCase()) {
				case 'darnell':
				rain.setIntenseValues(0.0, 0.1);
				useShader = true;
				case 'lit-up':
				rain.setIntenseValues(0.1, 0.2);
				useShader = true;
				case '2hot':
				rain.setIntenseValues(0.2, 0.4);
				useShader = true;
				case 'score':
				rain.setIntenseValues(0.1, 0.3);
				useShader = true;
			}
		}

        //Functions
        resetCar(true, true);
        //updateABotEye(true);

		if (isStoryMode)
		{
			switch (songName)
			{
				case 'darnell':
					if(!seenCutscene) setStartCallback(videoCutscene.bind('darnellCutscene'));
				case '2hot':
					setEndCallback(function()
					{
						game.endingSong = true;
						inCutscene = true;
						canPause = false;
						FlxTransitionableState.skipNextTransIn = true;
						FlxG.camera.visible = false;
						camHUD.visible = false;
						game.startVideo('2hotCutscene');
					});
			}
		}

    }

	var gunPrepSnd:FlxSound;
	var bonkSnd:FlxSound;
	var lightCanSnd:FlxSound;
	var kickCanSnd:FlxSound;
	var kneeCanSnd:FlxSound;
	var noteTypes:Array<String> = [];
    override function createPost()
    {
        if (useShader) 
		{
			rainFilter = new ShaderFilter(rain);
			ShaderUtils.applyFiltersToCams([camGame, camHUD], [rainFilter]);
			
			/*
			This comment is only here to explain the reflection.

			It should look like this:
			reflectedChar = new ReflectedChar(character, alpha, shader);

			What it does is takes the data from the character and technically makes a new character. Then it flips it, applies an offset
			to not look weird with the animations, applies the alpha value to make it more transparent/opaque, and then it stores the main 
			character as a variable so that it can update it's animations to match the reflected character.

			Make sure to use "addBehindBF", "addBehindGF", and "addBehindDad" instead of "add" so that the reflected character is below the proper character it needs to be.
			*/

			reflectedBF = new ReflectedChar(boyfriend, 0.35);
			addBehindBF(reflectedBF);
		}
        add(phillySpray);
        add(spraycan);
        add(casingGroup);
		precache();
		lightCanSnd = new FlxSound();
		FlxG.sound.list.add(lightCanSnd);
		lightCanSnd.loadEmbedded(Paths.sound('Darnell_Lighter'));
		
		kickCanSnd = new FlxSound();
		FlxG.sound.list.add(kickCanSnd);
		kickCanSnd.loadEmbedded(Paths.sound('Kick_Can_UP'));

		kneeCanSnd = new FlxSound();
		FlxG.sound.list.add(kneeCanSnd);
		kneeCanSnd.loadEmbedded(Paths.sound('Kick_Can_FORWARD'));

		bonkSnd = new FlxSound();
		FlxG.sound.list.add(bonkSnd);
		bonkSnd.loadEmbedded(Paths.sound('Pico_Bonk'));

		gunPrepSnd = new FlxSound();
		FlxG.sound.list.add(gunPrepSnd);
		gunPrepSnd.loadEmbedded(Paths.sound('Gun_Prep'));

		/*if(gf != null)
		{
			gf.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
			{
				switch(currentNeneState)
				{
					case STATE_PRE_RAISE:
						if (name == 'danceLeft' && frameNumber >= 14)
						{
							animationFinished = true;
							transitionState();
						}
					default:
						// Ignore.
				}
			}
		}
		*/

    }

	#if VIDEOS_ALLOWED
	var videoEnded:Bool = false;
	#else
	var videoEnded:Bool = true; 
	#end
	function videoCutscene(?videoName:String = null)
	{
		game.inCutscene = true;

		#if VIDEOS_ALLOWED
		if(!videoEnded && videoName != null)
		{
			game.startVideo(videoName, true);
			game.video.onEndReached.add(function()
			{
				videoEnded = true;
				game.video = null;
				darnellCutscene();
			});
			return;
		}
		#end
	}

	function precache()
	{
		var didCreateCan = false;
		function createCan()
		{
			if(didCreateCan) return;
			spraycan = new SpraycanAtlasSprite(phillySpray.x + 530, phillySpray.y - 240);
			add(spraycan);
			didCreateCan = true;

		}

		var didCreateCasing = false;
		function precacheCasing()
		{
			if(didCreateCasing) return;
			if(!ClientPrefs.data.lowQuality)
			{
				casingFrames = Paths.getSparrowAtlas('PicoBullet'); //precache
				casingGroup = new FlxSpriteGroup();
				add(casingGroup);
			}
			didCreateCasing = true;
		}

		for (noteType in noteTypes)
		{
			switch(noteType)
			{
				case 'weekend-1-kickcan':
					createCan();
				case 'weekend-1-reload':
					precacheCasing();

			}
		}
		
		if(isStoryMode && !seenCutscene)
		{
			switch(songName)
			{
				case 'darnell':
					createCan();
					precacheCasing();
			}
		}

		for (i in 1...5)
			Paths.sound('shots/shot$i');
	}

    function prepareCutscene()
	{
		inCutsceneDarnell = true;
		seenDarnellCutscene = false;
		picoPos = [boyfriend.getMidpoint().x -400 - boyfriend.cameraPosition[0] - game.boyfriendCameraOffset[0],  boyfriend.getMidpoint().y - 100 + boyfriend.cameraPosition[1] + game.boyfriendCameraOffset[1]];
		dadPos = [dad.getMidpoint().x + 150 + dad.cameraPosition[0] + game.opponentCameraOffset[0], dad.getMidpoint().y - 100 + dad.cameraPosition[1] + game.opponentCameraOffset[1]];

		game.isCameraOnForcedPos = true;
		cutsceneHandler = new CutsceneHandler();

		boyfriendGroup.alpha = 0.00001;
		camHUD.visible = false;

		picoIntro1 = new Character(1939, 454, "pico-intro", true);
		picoIntro1.x += picoIntro1.positionArray[0];
		picoIntro1.y += picoIntro1.positionArray[1];
		add(picoIntro1);

		picoIntro2 = new Character(1939, 454, "pico-intro2", true);
		picoIntro2.x += picoIntro2.positionArray[0];
		picoIntro2.y += picoIntro2.positionArray[1];
		add(picoIntro2);
		picoIntro2.alpha = 0.00001;

		if (useShader)
		{
			reflectedBF.destroy();
			reflectedBF = new ReflectedChar(picoIntro1, 0.35);
			addBehindBF(reflectedBF);
		}

		camFollow.setPosition(picoPos[0] + 250, picoPos[1]);

		cutsceneHandler.finishCallback = function()
		{
			game.tweenCameraZoom(0.77, 2, true, FlxEase.sineInOut);
			game.tweenCameraToPosition(dadPos[0]+180, dadPos[1], 2, FlxEase.sineInOut);
			var timeForStuff:Float = Conductor.crochet / 1000 * 4.5;
			FlxG.sound.music.fadeOut(timeForStuff);
			spraycan.cutscene = false;
			spraycan.visible = spraycan.active = spraycan.cutscene = false;
			spraycan.destroy();
			startCountdown();

			camHUD.visible = true;
			FlxTween.tween(camHUD, {alpha: 1}, 2, {ease: FlxEase.sineInOut});
			boyfriend.animation.finishCallback = null;
			dad.animation.finishCallback = null;
		};

	}

	function darnellCutscene()
	{

		prepareCutscene();
		blackScreen = new FlxSprite(-300,-170).makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), FlxColor.BLACK);
		blackScreen.scrollFactor.set();
		add(blackScreen);

		FlxG.camera.zoom = 1.3;
		spraycan.cutscene = true;

		cutsceneHandler.endTime = 10;

		var cutsceneMusic:FlxSound = new FlxSound().loadEmbedded(Paths.music('darnellCanCutscene'));
		cutsceneMusic.looped = true;
		FlxG.sound.list.add(cutsceneMusic);

		var darnellLaugh:FlxSound = new FlxSound().loadEmbedded(Paths.sound('cutscene/darnell_laugh'));
		darnellLaugh.volume = 0.6;
		FlxG.sound.list.add(darnellLaugh);

		var neneLaugh:FlxSound = new FlxSound().loadEmbedded(Paths.sound('cutscene/nene_laugh'));
		neneLaugh.volume = 0.6;
		FlxG.sound.list.add(neneLaugh);

		
		camHUD.alpha = 0;
		gf.animation.finishCallback = function(name:String)
		{
			switch(name)
			{
				case 'danceLeft', 'danceRight':
					gf.dance();
			}
		}
		gf.dance();

		dad.animation.finishCallback = function(name:String)
		{
			switch(name)
			{
				case 'idle':
					dad.dance();
			}
		}
		dad.dance();

		cutsceneHandler.timer(0.1, function()
		{
			game.tweenCameraZoom(1.3, 0, true, FlxEase.quadInOut);
			game.tweenCameraToPosition(picoPos[0] + 250, picoPos[1], 0, FlxEase.sineInOut);
			picoIntro1.playAnim("pissed", true);
			gf.playAnim("intro", true);
			dad.playAnim("intro", true);
		});
		
		var cutsceneSnd:FlxSound = new FlxSound().loadEmbedded(Paths.sound('darnellCanCutscene'));
		FlxG.sound.list.add(cutsceneSnd);
		
		cutsceneHandler.timer(0.7, function()
		{
			cutsceneSnd.play(true);
			FlxTween.tween(blackScreen, { alpha: 0}, 2, {startDelay: 0.3});
		});

		cutsceneHandler.timer(2, function()
		{
			game.tweenCameraToPosition(dadPos[0]+150, dadPos[1], 2.5, FlxEase.sineInOut);
			FlxTween.tween(FlxG.camera, {zoom: 0.66}, 2.5, {ease: FlxEase.quadInOut});
		});

		cutsceneHandler.timer(5, function()
		{
			dad.playAnim("lightCan", true);
			lightCanSnd.play(true);
		});
		
		cutsceneHandler.timer(6.3, function()
		{
			picoIntro1.alpha = 0.00001;
			picoIntro2.alpha = 1;
			reflectedBF.destroy();
			reflectedBF = new ReflectedChar(picoIntro2, 0.35);
			addBehindBF(reflectedBF);
			picoIntro2.playAnim("reload", true);
			gunPrepSnd.play(true);
			game.tweenCameraToPosition(dadPos[0]+180, dadPos[1], 0.4, FlxEase.backOut);
		});
		cutsceneHandler.timer(6.466, function() createCasing());

		cutsceneHandler.timer(6.65, function()
		{
			dad.playAnim("kickCan", true);
			spraycan.playCanStart();
			kickCanSnd.play(true);
		});

		cutsceneHandler.timer(6.97, function()
		{
			picoIntro2.alpha = 0.00001;
			picoIntro1.alpha = 1;
			if (useShader)
			{
				reflectedBF.destroy();
				reflectedBF = new ReflectedChar(picoIntro1, 0.35);
				addBehindBF(reflectedBF);
			}
		});

		cutsceneHandler.timer(7.0, function()
		{
			dad.playAnim("kneeCan", true);
			kneeCanSnd.play(true);
			picoIntro1.playAnim("return", true);
		});

		cutsceneHandler.timer(7.1, function()
		{
			game.tweenCameraToPosition(dadPos[0]+100, dadPos[1], 1, FlxEase.quadInOut);
			FlxG.sound.play(Paths.soundRandom('shots/shot', 1, 4));
			spraycan.playCanShot();
			new FlxTimer().start(1/24, function(_)
			{
				darkenStageProps();
			});
			FlxTween.tween(spraycan, {alpha : 0}, 1, {ease: FlxEase.quadInOut});
		});

		cutsceneHandler.timer(7.9, function()
		{
			dad.playAnim("laughCutscene", true);
			darnellLaugh.play(true);
		});
		
		cutsceneHandler.timer(8.2, function()
		{
			gf.animation.finishCallback = null;
			gf.playAnim('laughCutscene', true);
			neneLaugh.play(true);
		});

		cutsceneHandler.timer(8.7, function()
		{
			inCutsceneDarnell = false;
		});

	}

	//var currentNeneState:NeneState = STATE_DEFAULT;
	//var animationFinished:Bool = false;
    override function update(elapsed:Float)
	{
		//rain.shader.update(elapsed * rainTimeScale);
		if(ClientPrefs.data.shaders)
			rain.update(elapsed * rainTimeScale);
			rain.lerpRatio = Math.max(0, Conductor.songPosition - ClientPrefs.data.noteOffset) / FlxG.sound.music.length;
		    rainTimeScale = MathUtil.coolLerp(rainTimeScale, rainScaler, 0.05);
		/*if(gf.animation.curAnim.name == "Idle-alt"){
            blinkTime -= elapsed;

            if(blinkTime <= 0){
                gf.playAnim("idle-alt", true);
                blinkTime = FlxG.random.float(BLINK_MIN, BLINK_MAX);
            }
        }

		if(gf == null || !game.startedCountdown) return;

		animationFinished = gf.isAnimationFinished();
		transitionState();
		*/

		super.update(elapsed);
	}

	/*function transitionState() {
		switch (currentNeneState)
		{
			case STATE_DEFAULT:
				if (game.health <= VULTURE_THRESHOLD)
				{
					currentNeneState = STATE_PRE_RAISE;
					gf.skipDance = true;
				}

			case STATE_PRE_RAISE:
				if (game.health > VULTURE_THRESHOLD)
				{
					currentNeneState = STATE_DEFAULT;
					gf.skipDance = false;
				}
				else if (animationFinished)
				{
					currentNeneState = STATE_RAISE;
					gf.playAnim('raiseKnife');
					gf.skipDance = true;
					gf.danced = true;
					animationFinished = false;
				}

			case STATE_RAISE:
				if (animationFinished)
				{
					currentNeneState = STATE_READY;
					animationFinished = false;
				}

			case STATE_READY:
				if (game.health > VULTURE_THRESHOLD)
				{
					currentNeneState = STATE_LOWER;
					gf.playAnim('lowerKnife');
				}

			case STATE_LOWER:
				if (animationFinished)
				{
					currentNeneState = STATE_DEFAULT;
					animationFinished = false;
					gf.skipDance = false;
				}
		}
	}*/

    override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "Change Character":
				if (value1.toLowerCase() == "bf" || value1.toLowerCase() == "boyfriend" || value1.toLowerCase() == "player") {
					if (useShader)
					{
						reflectedBF.destroy();
						reflectedBF = new ReflectedChar(boyfriend, 0.35);
						addBehindBF(reflectedBF);
					}
				} 
				if (value1.toLowerCase() == "dad" || value1.toLowerCase() == "enemy" || value1.toLowerCase() == "opponent") {
					reflectedDad.destroy();
					reflectedDad = new ReflectedChar(dad, 0.35);
					addBehindDad(reflectedDad);
				}
				if (value1.toLowerCase() == 'gf' || value1.toLowerCase() == 'girlfriend') {
					reflectedGF.destroy();
					reflectedGF = new ReflectedChar(gf, 0.35);
					addBehindGF(reflectedGF);
				} 
		}
	}

    /*override function sectionHit()
	{
		updateABotEye();
	}
	*/

	/*function updateABotEye(finishInstantly:Bool = false)
	{
		if(PlayState.SONG.notes[Std.int(FlxMath.bound(curSection, 0, PlayState.SONG.notes.length - 1))].mustHitSection == true)
			abot.lookRight();
		else
			abot.lookLeft();

		if(finishInstantly) abot.eyes.anim.curFrame = abot.eyes.anim.length - 1;
	}
	*/

	override function countdownTick(count:Countdown, num:Int) {
		if (isStoryMode && !seenDarnellCutscene)
		{
			if (num == 3)
			{
				new FlxTimer().start(0.5, function(tmr)
				{
					picoIntro1.alpha = 0.00001;
					boyfriendGroup.alpha = 1;
					reflectedBF.destroy();
					reflectedBF = new ReflectedChar(boyfriend, 0.35);
					game.isCameraOnForcedPos = false;
					addBehindBF(reflectedBF);
					// Since these aren't getting used in the rest of the song after cutscene, remove them
					if (picoIntro1 != null && picoIntro2 != null) {
						picoIntro1.destroy();
						picoIntro2.destroy();
					}
				});
			}
		}
	}

    override function beatHit() 
	{
		//abot.bop();
		// Try driving a car when its possible
		if (FlxG.random.bool(10) && curBeat != (lastChange + changeInterval) && carInterruptable == true)
		{
			if(lightsStop == false){
				driveCar(phillyCars);
			}
			else{
				driveCarLights(phillyCars);
			}
		}
		
		// try driving one on the right too. in this case theres no red light logic, it just can only spawn on green lights
		if(FlxG.random.bool(10) && curBeat != (lastChange + changeInterval) && car2Interruptable == true && lightsStop == false) driveCarBack(phillyCarsBack);
	
		// After the interval has been hit, change the light state.
		if (curBeat == (lastChange + changeInterval)) changeLights(curBeat);

		/*if(PlayState.SONG.song.toLowerCase() != "blazin"){
            if(game.health < 0.4 && !knifeRaised){
                knifeRaised = true;
				gf.idleSuffix = "-alt";
				gf.recalculateDanceIdle();
                blinkTime = FlxG.random.float(BLINK_MIN, BLINK_MAX);
                gf.playAnim("raiseKnife", true);

            } 
            else if(game.health >= 0.4 && knifeRaised && gf.animation.curAnim.name == "idle-alt"){
                knifeRaised = false;
                gf.playAnim("lowerKnife", true);
				gf.idleSuffix = "";
				gf.recalculateDanceIdle();
            }
        }
		*/
	}

	function changeLights(beat:Int):Void{

		lastChange = beat;
		lightsStop = !lightsStop;

		if(lightsStop){
			phillyTraffic.animation.play('tored');
			changeInterval = 20;
		} else {
			phillyTraffic.animation.play('togreen');
			changeInterval = 30;

			if(carWaiting == true) finishCarLights(phillyCars);
		}
	}

	function resetCar(left:Bool, right:Bool){
		if(left){
			carWaiting = false;
			carInterruptable = true;
			if (phillyCars != null) {
				FlxTween.cancelTweensOf(phillyCars);
				phillyCars.x = 1200;
				phillyCars.y = 400;
				phillyCars.angle = 0;
			}
		}

		if(right){
			car2Interruptable = true;
			if (phillyCarsBack != null) {
				FlxTween.cancelTweensOf(phillyCarsBack);
				phillyCarsBack.x = 1200;
				phillyCarsBack.y = 400;
				phillyCarsBack.angle = 0;
			}
		}
	}

	function finishCarLights(sprite:FlxSprite):Void	{
		carWaiting = false;
		var duration:Float = FlxG.random.float(1.8, 3);
		var rotations:Array<Int> = [-5, 18];
		var offset:Array<Float> = [306.6, 168.3];
		var startdelay:Float = FlxG.random.float(0.2, 1.2);

		var path:Array<FlxPoint> = [
			FlxPoint.get(1950 - offset[0] - 80, (980 - offset[1] + 15) - 265),
			FlxPoint.get(2400 - offset[0], (980 - offset[1] - 50) - 265),
			FlxPoint.get(3102 - offset[0], (1127 - offset[1] + 40) - 265)
		];

		FlxTween.angle(sprite, rotations[0], rotations[1], duration, {ease: FlxEase.sineIn, startDelay: startdelay} );
		FlxTween.quadPath(sprite, path, duration, true,
		{
			ease: FlxEase.sineIn,
			startDelay: startdelay,
			onComplete: function(_) {
				carInterruptable = true;
			}
		});
	}

	function driveCarLights(sprite:FlxSprite):Void {
		carInterruptable = false;
		FlxTween.cancelTweensOf(sprite);
		var variant:Int = FlxG.random.int(1,4);
		sprite.animation.play('car' + variant);
		var extraOffset = [0, 0];
		var duration:Float = 2;

		switch(variant){
			case 1:
				duration = FlxG.random.float(1, 1.7);
			case 2:
				extraOffset = [20, -15];
				duration = FlxG.random.float(0.9, 1.5);
			case 3:
				extraOffset = [30, 50];
				duration = FlxG.random.float(1.5, 2.5);
			case 4:
				extraOffset = [10, 60];
				duration = FlxG.random.float(1.5, 2.5);
		}
		
		var rotations:Array<Int> = [-7, -5];
		var offset:Array<Float> = [306.6, 168.3];
		sprite.offset.set(extraOffset[0], extraOffset[1]);

		var path:Array<FlxPoint> = [
			FlxPoint.get(1500 - offset[0] - 20, (1049 - offset[1] - 20) - 265),
			FlxPoint.get(1770 - offset[0] - 80, (994 - offset[1] + 10) - 265),
			FlxPoint.get(1950 - offset[0] - 80, (980 - offset[1] + 15) - 265)
		];
		// debug shit!!! keeping it here just in case
		// for(point in path){
		// 	var debug:FlxSprite = new FlxSprite(point.x - 5, point.y - 5).makeGraphic(10, 10, 0xFFFF0000);
		// 	add(debug);
		// }
		FlxTween.angle(sprite, rotations[0], rotations[1], duration, {ease: FlxEase.cubeOut} );
		FlxTween.quadPath(sprite, path, duration, true,
		{
			ease: FlxEase.cubeOut,
			onComplete: function(_) {
				carWaiting = true;
				if(lightsStop == false) finishCarLights(phillyCars);
			}
		});
	}

	/**
	* Drives a car across the screen without stopping.
	* Used when the lights are green.
	*/
	function driveCar(sprite:FlxSprite):Void {
		carInterruptable = false;
		FlxTween.cancelTweensOf(sprite);
		var variant:Int = FlxG.random.int(1,4);
		sprite.animation.play('car' + variant);
		// setting an offset here because the current implementation of stage prop offsets was not working at all for me
		// if possible id love to not have to do this but im keeping this for now
		var extraOffset = [0, 0];
		var duration:Float = 2;
		// set different values of speed for the car types (and the offset)
		switch(variant){
			case 1:
				duration = FlxG.random.float(1, 1.7);
			case 2:
				extraOffset = [20, -15];
				duration = FlxG.random.float(0.6, 1.2);
			case 3:
				extraOffset = [30, 50];
				duration = FlxG.random.float(1.5, 2.5);
			case 4:
				extraOffset = [10, 60];
				duration = FlxG.random.float(1.5, 2.5);
		}
		// random arbitrary values for getting the cars in place
		// could just add them to the points but im LAZY!!!!!!
		var offset:Array<Float> = [306.6, 168.3];
		sprite.offset.set(extraOffset[0], extraOffset[1]);
		// start/end rotation
		var rotations:Array<Int> = [-8, 18];
		// the path to move the car on
		var path:Array<FlxPoint> = [
			FlxPoint.get(1570 - offset[0], (1049 - offset[1] - 30) - 265),
			FlxPoint.get(2400 - offset[0], (980 - offset[1] - 50) - 265),
			FlxPoint.get(3102 - offset[0], (1127 - offset[1] + 40) - 265)
		];

		FlxTween.angle(sprite, rotations[0], rotations[1], duration, null );
		FlxTween.quadPath(sprite, path, duration, true,
		{
			ease: null,
			onComplete: function(_) {
				carInterruptable = true;
			}
		});
	}

	function driveCarBack(sprite:FlxSprite):Void {
		car2Interruptable = false;
		FlxTween.cancelTweensOf(sprite);
		var variant:Int = FlxG.random.int(1,4);
		sprite.animation.play('car' + variant);
		// setting an offset here because the current implementation of stage prop offsets was not working at all for me
		// if possible id love to not have to do this but im keeping this for now
		var extraOffset = [0, 0];
		var duration:Float = 2;
		// set different values of speed for the car types (and the offset)
		switch(variant){
			case 1:
				duration = FlxG.random.float(1, 1.7);
			case 2:
				extraOffset = [20, -15];
				duration = FlxG.random.float(0.6, 1.2);
			case 3:
				extraOffset = [30, 50];
				duration = FlxG.random.float(1.5, 2.5);
			case 4:
				extraOffset = [10, 60];
				duration = FlxG.random.float(1.5, 2.5);
		}
		var offset:Array<Float> = [306.6, 168.3];
		sprite.offset.set(extraOffset[0], extraOffset[1]);
		var rotations:Array<Int> = [18, -8];
		var path:Array<FlxPoint> = [
				FlxPoint.get(3102 - offset[0], (1127 - offset[1] + 60) - 265),
				FlxPoint.get(2400 - offset[0], (980 - offset[1] - 30) - 265),
				FlxPoint.get(1570 - offset[0], (1049 - offset[1] - 10) - 265)

		];

		FlxTween.angle(sprite, rotations[0], rotations[1], duration, null );
		FlxTween.quadPath(sprite, path, duration, true,
		{
			ease: null,
			onComplete: function(_) {
				car2Interruptable = true;
			}
		});
	}

   /* override function setAudioAndStart(isStart:Bool)
	{
		if (isStart)
		{
			abot.setAudioSource(FlxG.sound.music);
			abot.startVisualizer();
		}
		else
		{
			abot.setAudioSource(null);
		}
	}
	*/

    /*override function startSong()
	{
		gf.animation.finishCallback = onNeneAnimationFinished;
	}
	
	function onNeneAnimationFinished(name:String)
	{
		if(!game.startedCountdown) return;

		switch(currentNeneState)
		{
			case STATE_RAISE, STATE_LOWER:
				if (name == 'raiseKnife' || name == 'lowerKnife')
				{
					animationFinished = true;
					transitionState();
				}

			default:
				// Ignore.
		}
	}*/

	override function goodNoteHit(note:Note)
	{
		
		// 10% chance of playing comboCheer/comboCheerHigh animations for Nene
		/*if(FlxG.random.bool(10))
		{
			switch(game.combo)
			{
				case 50:
					gf.playAnim('comboCheer', true);
					gf.specialAnim = true;
					trace("yeiii");
				case 100:
					gf.playAnim('comboCheerHigh', true);
					gf.specialAnim = true;
					trace("yeii?");
			}
		}
		*/

		switch(note.noteType)
		{
			case 'weekend-1-reload': // HE'S NOT PULLING HIS COCK OUT CUZ I CHANGED THE NOTE NAME HAHAHA 
				boyfriend.holdTimer = 0;
				boyfriend.playAnim('cock', true);
				boyfriend.specialAnim = true;
				//gunPrepSnd.play();

				boyfriend.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
				{
					switch(name)
					{
						case 'cock':
							if(frameNumber == 3)
							{
								boyfriend.animation.callback = null;
								createCasing();
							}
						default: boyfriend.animation.callback = null;
					}
				}

				game.notes.forEachAlive(function(note:Note)
				{
					if(note.noteType == 'weekend-1-firegun')
						note.blockHit = false;
				});
				showPicoFade();

			case 'weekend-1-firegun':
				boyfriend.holdTimer = 0;
				boyfriend.playAnim('shoot', true);
				boyfriend.specialAnim = true;
				FlxG.sound.play(Paths.soundRandom('shots/shot', 1, 4));
				spraycan.playCanShot();

				new FlxTimer().start(1/24, function(tmr)
				{
					darkenStageProps();
				});

				FlxTween.tween(spraycan, {alpha : 0}, 1, {ease: FlxEase.quadInOut});
		}
	}

	var picoFlicker:FlxTimer = null;
	override function noteMiss(note:Note)
	{
		switch(note.noteType)
		{
			case 'weekend-1-firegun':
				boyfriend.playAnim('hurt', true);
				boyfriend.specialAnim = true;
				bonkSnd.play();
				spraycan.playHitPico();
				FlxTween.tween(spraycan, {alpha : 0}, 1, {ease: FlxEase.quadInOut});
				
				
				if(picoFlicker != null)
				{
					picoFlicker.cancel();
					picoFlicker.destroy();
				}
				picoFlicker = null;

				boyfriend.animation.finishCallback = function(name:String)
				{
					if (name == 'hurt' && game.health > 0.0 && !game.practiceMode && game.gameOverTimer == null)
					{
						//FlxFlicker was crashing so fuck it, FlxTimer all the way
						picoFlicker = new FlxTimer().start(1 / 30, function(tmr:FlxTimer)
						{
							boyfriend.visible = !boyfriend.visible;
							if(tmr.loopsLeft == 0)
							{
								boyfriend.visible = true;
								picoFlicker = new FlxTimer().start(1 / 60, function(tmr2:FlxTimer)
								{
									boyfriend.visible = !boyfriend.visible;
									if(tmr2.loopsLeft == 0)
									{
										boyfriend.visible = true;
										//trace('test 2');
									}
								}, 30);
							}
						}, 30);
						//trace('test');
					}
					boyfriend.animation.finishCallback = null;
				}
				
				game.health -= 0.4;
				if(game.health <= 0.0 && !game.practiceMode)
				{
					GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pico-explode';
					GameOverSubstate.loopSoundName = 'gameOverStart-pico-explode';
					GameOverSubstate.characterName = 'pico-explosion-dead';
				}
		}
	}

	override function opponentNoteHit(note:Note)
	{
		var sndTime:Float = note.strumTime - Conductor.songPosition;
		switch(note.noteType)
		{
			case 'weekend-1-lightcan':
				dad.holdTimer = 0;
				dad.playAnim('lightCan', true);
				dad.specialAnim = true;
				//lightCanSnd.play(true, sndTime - 65);

				game.focusedChar = game.dad;
				game.isCameraOnForcedPos = true;
				game.defaultCamZoom += 0.1;
				game.cameraSpeed = 2;
				camFollow.x -= 100;
			case 'weekend-1-kickcan':
				dad.holdTimer = 0;
				dad.playAnim('kickCan', true);
				dad.specialAnim = true;
				//kickCanSnd.play(true, sndTime - 50);
				spraycan.alpha = 1;
				spraycan.playCanStart();
				camFollow.x += 250;
				game.cameraSpeed = 1.5;
				game.defaultCamZoom -= 0.1;
				
				new FlxTimer().start(1.1, function(_) {
					game.isCameraOnForcedPos = false;
					game.moveCameraSection();
					game.cameraSpeed = 1;
				});
			case 'weekend-1-kneecan':
				dad.holdTimer = 0;
				dad.playAnim('kneeCan', true);
				dad.specialAnim = true;
				//kneeCanSnd.play(true, sndTime - 22);
		}
	}

	function darkenStageProps()
	{
		// Darken the background, then fade it back.
		for (sprite in darkenable)
		{
			// If not excluded, darken.
			sprite.color = 0xFF111111;
			new FlxTimer().start(1/24, (tmr) ->
			{
				sprite.color = 0xFF222222;
				FlxTween.color(sprite, 1.4, 0xFF222222, 0xFFFFFFFF);
			});
		}
	}

	function createCasing()
	{
		var casing:FlxSprite = new FlxSprite(boyfriend.x + 175, boyfriend.y + 150);
		casing.frames = casingFrames;
		casing.animation.addByPrefix('pop', 'Pop0', 24, false);
		casing.animation.addByPrefix('idle', 'Bullet0', 24, true);
		casing.animation.play('pop', true);
		
		casing.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
		{
			if (name == 'pop' && frameNumber == 40)
			{
				// Get the end position of the bullet dynamically.
				casing.x = casing.x + casing.frame.offset.x - 1;
				casing.y = casing.y + casing.frame.offset.y + 1;
		
				casing.angle = 125.1; // Copied from FLA
		
				// Okay this is the neat part, we can set the velocity and angular acceleration to make it roll without editing update().
				var randomFactorA:Float = FlxG.random.float(3, 10);
				var randomFactorB:Float = FlxG.random.float(1.0, 2.0);
				casing.velocity.x = 20 * randomFactorB;
				casing.drag.x = randomFactorA * randomFactorB;
		
		
				casing.angularVelocity = 100;
				// Calculated to ensure angular acceleration is maintained through the whole roll.
				casing.angularDrag = (casing.drag.x / casing.velocity.x) * 100;
		
				casing.animation.play('idle');
				casing.animation.callback = null; // Save performance.
			}
		};
		casingGroup.add(casing);
	}

	
	function showPicoFade()
	{
		if(ClientPrefs.data.lowQuality) return;

		picoFade.setPosition(boyfriend.x, boyfriend.y);
		picoFade.frames = boyfriend.frames;
		picoFade.frame = boyfriend.frame;
		picoFade.alpha = 0.3;
		picoFade.scale.set(1, 1);
		picoFade.updateHitbox();
		picoFade.visible = true;

		FlxTween.cancelTweensOf(picoFade.scale);
		FlxTween.cancelTweensOf(picoFade);
		FlxTween.tween(picoFade.scale, {x: 1.3, y: 1.3}, 0.4);
		FlxTween.tween(picoFade, {alpha: 0}, 0.4, {onComplete: (_) -> (picoFade.visible = false)});
	}

    function addAndDark(object:FlxSprite) {
		add(object); 
		darkenable.push(object);
	}
}