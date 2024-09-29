package states.stages;

import states.stages.objects.*;
import substates.GameOverSubstate;
import objects.Character;
import torchsthings.shaders.Rain;
import openfl.filters.ShaderFilter;

class Darnell extends BaseStage
{
	var darnellSky:BGSprite;
	var darnellEdificios:BGSprite;
	var darnellCalles:BGSprite;
	var darnellBolsas:BGSprite;
	var darnellSpeaker:BGSprite;
	var darnellLight:BGSprite;

	var rain:Rain = new Rain();
	var rainFilter:ShaderFilter;
	override function create() 
	{
		var _song = PlayState.SONG;
		if(_song.gameOverSound == null || _song.gameOverSound.trim().length < 1) GameOverSubstate.deathSoundName = 'pico_loss_sfx';
		if(_song.gameOverLoop == null || _song.gameOverLoop.trim().length < 1) GameOverSubstate.loopSoundName = 'GameoverPico';
		if(_song.gameOverEnd == null || _song.gameOverEnd.trim().length < 1) GameOverSubstate.endSoundName = 'gameOverEnd';
		if(_song.gameOverChar == null || _song.gameOverChar.trim().length < 1) GameOverSubstate.characterName = 'pico-dead';

		darnellSky = new BGSprite('stageImages/darnell/sky', -550, -300);
		add(darnellSky);
				
		darnellEdificios = new BGSprite('stageImages/darnell/edificio', -800, -140);
		add(darnellEdificios);

		darnellCalles = new BGSprite('stageImages/darnell/calle', -740, -200);
		add(darnellCalles);

		darnellBolsas = new BGSprite('stageImages/darnell/bolsa', -640, -190);
		add(darnellBolsas);
		
		darnellLight = new BGSprite('stageImages/darnell/luces', 420, 515, ['Luces']);
		add(darnellLight);
		
		darnellSpeaker = new BGSprite('stageImages/darnell/neneSpeak', 250, 470, ['speaker nene']);
		add(darnellSpeaker);

		rain.scale = FlxG.height / 200;
		rain.intensity = 0.5;
		rain.updateViewInfo(FlxG.width, FlxG.height, FlxG.camera);
		rainFilter = new ShaderFilter(rain);
				
	}

	override function countdownTick(count:Countdown, num:Int) everyoneDance();
	override function beatHit() everyoneDance();

	function everyoneDance()
		{
			if(!ClientPrefs.data.lowQuality)
				darnellLight.dance(true);
	
			darnellSpeaker.dance(true);
		}
}