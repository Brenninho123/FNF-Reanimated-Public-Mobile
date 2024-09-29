package states.stages;

import states.stages.objects.*;
import objects.Character;
import torchsthings.shaders.*;
import torchsfunctions.functions.ShaderUtils;
import openfl.filters.ShaderFilter;
import torchsthings.objects.ReflectedChar;
import substates.GameOverSubstate;

class StageWeek1 extends BaseStage
{
	var dadbattleBlack:BGSprite;
	var dadbattleGlowup:BGSprite;
	var dadbattleGlowdown:BGSprite;
	var dadbattleLight:BGSprite;
	var dadbattleFog:DadBattleFog;
	var crt:CRT = new CRT(false, true);
	var shaderFilter:ShaderFilter;
	var gfPixel:Character = null;
	var offsetState:Bool = false; // Literally only here to prevent a crash I found - Torch
	//var reflectedBF:ReflectedChar;
	//var reflectedDad:ReflectedChar;
	override function create()
	{
		offsetState = Std.isOfType(FlxG.state, options.NoteOffsetState);
		var bg:BGSprite = new BGSprite('stageImages/week1/stageback', -850, -580, 0.9, 0.9);
		bg.setGraphicSize(Std.int(bg.width * 2.3));
		bg.updateHitbox();
		add(bg);

		var stageFront:BGSprite = new BGSprite('stageImages/week1/stagefront', -900, 600, 0.9, 0.9);
		stageFront.setGraphicSize(Std.int(stageFront.width * 2.3));
		stageFront.updateHitbox();
		add(stageFront);
		if(!ClientPrefs.data.lowQuality) {
					/*var stageHorns:BGSprite = new BGSprite('stageImages/week1/Altavoces', -200, 400, 0.9, 0.9);
					stageHorns.setGraphicSize(Std.int(stageHorns.width * 2.1));
					stageHorns.updateHitbox();
					add(stageHorns);*/

					var stagelittlelights:BGSprite = new BGSprite('stageImages/week1/stage_light',  -300, -400, 1.2, 1.2);
					stagelittlelights.setGraphicSize(Std.int(stagelittlelights.width * 2.1));
					stagelittlelights.updateHitbox();
					add(stagelittlelights);

					var stageCurtains:BGSprite = new BGSprite('stageImages/week1/stagecurtains',  -800, -750, 1.2, 1.2);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 2.2));
					stageCurtains.updateHitbox();
					add(stageCurtains);
		}
		if (!offsetState) {
			switch(PlayState.SONG.song.toLowerCase()) {
				case 'test':
					gfPixel = new Character(330, 335, 'gf-pixel', true); // Made her a "player" so she would face the other way
					add(gfPixel);
					gfPixel.dance();
			}
		}
	}

	override function onGameOver() {
		if (reflectedBF != null && GameOverSubstate.instance.boyfriend != null) {
			reflectedBF.destroy();
		}
	}

	override function createPost() {
		if (!offsetState) {
			switch(PlayState.SONG.song.toLowerCase()) {
				case 'test':
					gf.x += 450;
					shaderFilter = new ShaderFilter(crt);
					ShaderUtils.applyFiltersToCams([camGame, camHUD, camOther], [shaderFilter]);
					reflectedBF = new ReflectedChar(boyfriend, 0.35);
					reflectedDad = new ReflectedChar(dad, 0.35);
					addBehindBF(reflectedBF);
					addBehindDad(reflectedDad);
			}
		}
	}

	var tween:FlxTween;

	override function update(elapsed:Float) {
		crt.update(elapsed);
		if (gfPixel != null) {
			if (gfPixel.animation.name != gf.animation.name) {
				gfPixel.animation.play(gf.animation.name, true);
			}
		}
		if (!offsetState) {
			if (PlayState.SONG.song.toLowerCase() == 'test') {
				if (game.focusedChar == boyfriend) {
					if (tween != null) {
						tween.cancel();
					}
					tween = FlxTween.tween(crt, {middle:0.425}, 2.7, {ease: FlxEase.elasticOut});
				} else {
					if (tween != null) {
						tween.cancel();
					}
					tween = FlxTween.tween(crt, {middle:0.57}, 2.7, {ease: FlxEase.elasticOut});
				}
			}
		}
	}

	override function eventPushed(event:objects.Note.EventNote)
	{
		switch(event.event)
		{
			case "Dadbattle Spotlight":
				dadbattleBlack = new BGSprite(null, -800, -400, 0, 0);
				dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				dadbattleBlack.alpha = 0.45;
				dadbattleBlack.visible = false;
				add(dadbattleBlack);

				dadbattleLight = new BGSprite('spotlight', 400, -400);
				dadbattleLight.alpha = 0.375;
				dadbattleLight.blend = ADD;
				dadbattleLight.visible = false;
				add(dadbattleLight);

				dadbattleGlowup = new BGSprite('stageImages/week1/light', -400, -400, 1.2, 1.2);
				dadbattleGlowup.setGraphicSize(Std.int(dadbattleGlowup.width * 2.3));
				dadbattleGlowup.updateHitbox();
				dadbattleGlowup.alpha = 0.75;
				dadbattleGlowup.blend = ADD;
				dadbattleGlowup.visible = false;
				add(dadbattleGlowup);

				dadbattleGlowdown = new BGSprite('stageImages/week1/light2', -700, 600, 0.9, 0.9);
				dadbattleGlowdown.setGraphicSize(Std.int(dadbattleGlowdown.width * 2.1));
				dadbattleGlowdown.updateHitbox();
				dadbattleGlowdown.alpha = 0.75;
				dadbattleGlowdown.blend = ADD;
				dadbattleGlowdown.visible = false;
				add(dadbattleGlowdown);

				dadbattleFog = new DadBattleFog();
				dadbattleFog.visible = false;
				add(dadbattleFog);
		}
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "Dadbattle Spotlight":
				if(flValue1 == null) flValue1 = 0;
				var val:Int = Math.round(flValue1);

				switch(val)
				{
					case 1, 2, 3: //enable and target dad
						if(val == 1) //enable
						{
							dadbattleBlack.visible = true;
							dadbattleGlowup.visible = true;
							dadbattleGlowdown.visible = true;
							dadbattleLight.visible = true;
							dadbattleFog.visible = true;
							defaultCamZoom += 0.12;
						}

						var who:Character = dad;
						if(val > 2) who = boyfriend;
						//2 only targets dad
						dadbattleLight.alpha = 0;
						new FlxTimer().start(0.12, function(tmr:FlxTimer) {
							dadbattleLight.alpha = 0.375;
						});
						// frameHeight grabs the proper pixel height for the frame, not just the actual height of the object
						dadbattleLight.setPosition(who.getGraphicMidpoint().x - dadbattleLight.width / 2, who.y + /*who.height*/ who.frameHeight - dadbattleLight.height + 50);
						FlxTween.tween(dadbattleFog, {alpha: 0.7}, 1.5, {ease: FlxEase.quadInOut});

					default:
						dadbattleBlack.visible = false;
						dadbattleGlowup.visible = false;
						dadbattleGlowdown.visible = false;
						dadbattleLight.visible = false;
						defaultCamZoom -= 0.12;
						FlxTween.tween(dadbattleFog, {alpha: 0}, 0.7, {onComplete: function(twn:FlxTween) dadbattleFog.visible = false});
				}
			case "Change Character":
				if (value1.toLowerCase() == "bf" || value1.toLowerCase() == "boyfriend" || value1.toLowerCase() == "player") {
					reflectedBF.destroy();
					reflectedBF = new ReflectedChar(boyfriend, 0.35);
					addBehindBF(reflectedBF);
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
}