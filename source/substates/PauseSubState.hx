package substates;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import flixel.addons.transition.FlxTransitionableState;

import flixel.util.FlxStringUtil;

import states.StoryMenuState;
import states.FreeplayState;
import states.MainMenuState;
import options.OptionsState;

import haxe.Json;
import tjson.TJSON;

import torchsthings.shaders.PixelShader.PixelShaderRef;
import torchsthings.states.CharacterMenu;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<FlxText>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Options', 'Exit to menu'];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var pauseMusicName:String;
	var practiceText:FlxText;
	var skipTimeText:FlxText;
	var skipTimeTracker:FlxText;
	var curTime:Float = Math.max(0, Conductor.songPosition);

	var missingTextBG:FlxSprite;
	var missingText:FlxText;
	var cancionpolla:String = PlayState.SONG.song;

	var charactersData:Array<Array<String>> = [
	//	['characterAssetName', 'x', 'y', 'graphicScale', 'Artist', 'PixelBlockSize' (for shader, 6 is default)],
		['Sentao', '750', '250', '0.9', 'Law', '6'],
		['jorge', '675', '0', '0.7', 'Dafne', '8'],
		['jorege', '700', '190', '0.7', 'z3mp', '8'],
		['zeta3emepe', '700', '190', '0.7', 'z3mp', '8'],
		['snax', '750', '190', '0.3', "ImSnax", '10'],
		['Roxy', '700', '70', '0.2', "SaNicbOom", '12'],
		['Jeyzel', '650', '80', '0.3', "Jeyzel Arts", '12'],
		['Torch', '750', '180', '1.4', "Callisto", '3'],
		['olaa uwu', '350', '180', '0.8', "z3mp", '6'],
		['BFRock', '750', '320', '0.9', "Phantom Arcade", '4'],
		['Alejandro', '700', '70', '0.9', "ElDiezMixta", '6'],
	];
	var randomCharacternum:Int;
	var character:BGSprite;

	public static var songName:String = null;
	
	var pixelShader:PixelShaderRef = new PixelShaderRef(PlayState.daPixelZoom);

	override function create()
	{
		switch(PlayState.curStage)
		{
			case 'phillyStreets' | 'phillyBlazin':
				pauseMusicName = 'breakfast-pico';
			case 'school' | 'schoolEvil':
				pauseMusicName = 'breakfast-pixel';
			case 'robin':
				pauseMusicName = 'iconoclast';
			default:
				pauseMusicName = getPauseSong();

		}
		if(Difficulty.list.length < 2) menuItemsOG.remove('Change Difficulty'); //No need to change difficulty if there is only one!

		if(PlayState.chartingMode)
		{
			menuItemsOG.insert(2, 'Leave Charting Mode');
			
			var num:Int = 0;
			if(!PlayState.instance.startingSong)
			{
				num = 1;
				menuItemsOG.insert(3, 'Skip Time');
			}
			menuItemsOG.insert(3 + num, 'End Song');
			menuItemsOG.insert(4 + num, 'Toggle Practice Mode');
			menuItemsOG.insert(5 + num, 'Toggle Botplay');
		}
		if (CharacterMenu.usedCharMenu) {
			menuItemsOG.insert(menuItemsOG.indexOf("Exit to menu"), 'Change Character');
		}
		menuItems = menuItemsOG;

		for (i in 0...Difficulty.list.length) {
			var diff:String = Difficulty.getString(i);
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');


		pauseMusic = new FlxSound();
		try
		{
			var pauseSong:String = pauseMusicName;
			if(pauseSong != null) pauseMusic.loadEmbedded(Paths.music(pauseSong), true, true);
		}
		catch(e:Dynamic) {}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		randomCharacternum = FlxG.random.int(0, charactersData.length - 1);
		var charName:String = charactersData[randomCharacternum][0];
		var charOffsets:Array<Int> = [Std.parseInt(charactersData[randomCharacternum][1]), Std.parseInt(charactersData[randomCharacternum][2])];
		var charScale:Float = Std.parseFloat(charactersData[randomCharacternum][3]);
		var artCredit:String = charactersData[randomCharacternum][4];
		character = new BGSprite('pauseScreenChar/' + charName, 1000, charOffsets[1], 1.0, 1.0);
		character.antialiasing = ClientPrefs.data.antialiasing;
		character.setGraphicSize(Std.int(character.width * charScale));
		character.updateHitbox();
		add(character);
		FlxTween.tween(character,{alpha: 1},0.5,{ease: FlxEase.linear});
		FlxTween.tween(character,{x: charOffsets[0]},0.5,{ease: FlxEase.sineOut});
		if (PlayState.isPixelStage) character.shader = pixelShader.shader;
		pixelShader.updateBlockSize(Std.parseInt(charactersData[randomCharacternum][5]));

		var levelInfo:FlxText = new FlxText(20, 15, 0, PlayState.SONG.song, 32);
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font(PlayState.isPixelStage ? "pixel.otf" : "PhantomMuff.ttf"), PlayState.isPixelStage ? 20 : 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, Difficulty.getString().toUpperCase(), 32);
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font(PlayState.isPixelStage ? "pixel.otf" : 'PhantomMuff.ttf'), PlayState.isPixelStage ? 20 : 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var blueballedTxt:FlxText = new FlxText(20, 15 + 64, 0, "Blueballed: " + PlayState.deathCounter, 32);
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font(PlayState.isPixelStage ? "pixel.otf" : 'PhantomMuff.ttf'), PlayState.isPixelStage ? 20 : 32, FlxColor.fromRGB(0, 255, 255), null, OUTLINE, FlxColor.BLACK);
		blueballedTxt.borderSize = 2;
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		var artCredits:FlxText = new FlxText(20, 680, 0, "Art By: " + artCredit, 25);
		artCredits.scrollFactor.set();
		artCredits.setFormat(Paths.font(PlayState.isPixelStage ? "pixel.otf" : 'PhantomMuff.ttf'), PlayState.isPixelStage ? 15 : 25);
		artCredits.updateHitbox();
		add(artCredits);

		practiceText = new FlxText(20, 15 + 101, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font(PlayState.isPixelStage ? "pixel.otf" : 'PhantomMuff.ttf'), PlayState.isPixelStage ? 20 : 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		var path = "";
		if (FileSystem.exists(Paths.json(cancionpolla + '/credits'))) {
			path = File.getContent(Paths.json(cancionpolla + '/credits'));
		} 
		#if MODS_ALLOWED
		else 
		if (FileSystem.exists(Paths.modsJson(cancionpolla + '/credits'))){
			path = File.getContent(Paths.modsJson(cancionpolla + '/credits'));
		}
		#end
		else {
			path = '
			{
				"artist": "Unknown",
				"charter": "Unknown"
			}
			';		
		}

		var jsonObj = tjson.TJSON.parse(path);
		var creditsTxt:FlxText = new FlxText(500, 20, 0, "> credits:\nmusic by: " + jsonObj.artist + "\nchart by: " + jsonObj.charter);
		creditsTxt.scrollFactor.set();
		creditsTxt.setFormat(Paths.font(PlayState.isPixelStage ? "pixel.otf" : 'PhantomMuff.ttf'), PlayState.isPixelStage ? 18 : 28);
		creditsTxt.updateHitbox();
		creditsTxt.alpha = 0;
		add(creditsTxt);
		FlxTween.tween(creditsTxt, {alpha: 1}, 0.5, {ease: FlxEase.linear});
		FlxTween.tween(creditsTxt, {x: 20}, 0.5, {ease: FlxEase.sineOut});

		var chartingText:FlxText = new FlxText(20, 15 + 101, 0, "CHARTING MODE", 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font(PlayState.isPixelStage ? "pixel.otf" : 'PhantomMuff.ttf'), PlayState.isPixelStage ? 20 : 32);
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		blueballedTxt.alpha = 0;
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);
		artCredits.x = FlxG.width - (artCredits.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<FlxText>();
		add(grpMenuShit);

		missingTextBG = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		missingTextBG.scale.set(FlxG.width, FlxG.height);
		missingTextBG.updateHitbox();
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font(PlayState.isPixelStage ? "pixel.otf" : "PhantomMuff.ttf"), PlayState.isPixelStage ? 14 : 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		firstRegenMenu();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		super.create();
	}
	
	function getPauseSong()
	{
		var formattedSongName:String = (songName != null ? Paths.formatToSongPath(songName) : '');
		var formattedPauseMusic:String = Paths.formatToSongPath(ClientPrefs.data.pauseMusic);
		if(formattedSongName == 'none' || (formattedSongName != 'none' && formattedPauseMusic == 'none')) return null;

		return (formattedSongName != '') ? formattedSongName : formattedPauseMusic;
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		if(controls.BACK)
		{
			close();
			return;
		}

		updateSkipTextStuff();
		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		var daSelected:String = menuItems[curSelected];
		switch (daSelected)
		{
			case 'Skip Time':
				if (controls.UI_LEFT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime -= 1000;
					holdTime = 0;
				}
				if (controls.UI_RIGHT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime += 1000;
					holdTime = 0;
				}

				if(controls.UI_LEFT || controls.UI_RIGHT)
				{
					holdTime += elapsed;
					if(holdTime > 0.5)
					{
						curTime += 45000 * elapsed * (controls.UI_LEFT ? -1 : 1);
					}

					if(curTime >= FlxG.sound.music.length) curTime -= FlxG.sound.music.length;
					else if(curTime < 0) curTime += FlxG.sound.music.length;
					updateSkipTimeText();
				}
		}

		if (controls.ACCEPT && (cantUnpause <= 0 || !controls.controllerMode))
		{
			if (menuItems == difficultyChoices)
			{
				try{
					if(menuItems.length - 1 != curSelected && difficultyChoices.contains(daSelected)) {

						var name:String = PlayState.SONG.song;
						var poop = Highscore.formatSong(name, curSelected);
						PlayState.SONG = Song.loadFromJson(poop, name);
						PlayState.storyDifficulty = curSelected;
						MusicBeatState.resetState();
						FlxG.sound.music.volume = 0;
						PlayState.changedDifficulty = true;
						PlayState.chartingMode = false;
						return;
					}					
				}catch(e:Dynamic){
					trace('ERROR! $e');

					var errorStr:String = e.toString();
					if(errorStr.startsWith('[file_contents,assets/data/')) errorStr = 'Missing file: ' + errorStr.substring(27, errorStr.length-1); //Missing chart
					missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
					missingText.screenCenter(Y);
					missingText.visible = true;
					missingTextBG.visible = true;
					FlxG.sound.play(Paths.sound('cancelMenu'));

					super.update(elapsed);
					return;
				}


				menuItems = menuItemsOG;
				regenMenu();
			}

			switch (daSelected)
			{
				case "Resume":
					close();
				case 'Change Difficulty':
					menuItems = difficultyChoices;
					deleteSkipTimeText();
					regenMenu();
				case 'Toggle Practice Mode':
					PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
					PlayState.changedDifficulty = true;
					practiceText.visible = PlayState.instance.practiceMode;
				case "Restart Song":
					restartSong();
				case "Leave Charting Mode":
					restartSong();
					PlayState.chartingMode = false;
				case 'Skip Time':
					if(curTime < Conductor.songPosition)
					{
						PlayState.startOnTime = curTime;
						restartSong(true);
					}
					else
					{
						if (curTime != Conductor.songPosition)
						{
							PlayState.instance.clearNotesBefore(curTime);
							PlayState.instance.setSongTime(curTime);
						}
						close();
					}
				case 'End Song':
					close();
					PlayState.instance.notes.clear();
					PlayState.instance.unspawnNotes = [];
					PlayState.instance.finishSong(true);
				case 'Toggle Botplay':
					PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
					PlayState.changedDifficulty = true;
					PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
					PlayState.instance.botplayTxt.alpha = 1;
					PlayState.instance.botplaySine = 0;
				case 'Options':
					PlayState.instance.paused = true; // For lua
					PlayState.instance.vocals.volume = 0;
					MusicBeatState.switchState(new OptionsState());
					if(ClientPrefs.data.pauseMusic != 'None')
					{
						FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)), pauseMusic.volume);
						FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
						FlxG.sound.music.time = pauseMusic.time;
					}
					OptionsState.onPlayState = true;
				case "Change Character":
					var notChosen:Bool = true;
					for (array in CharacterMenu.specificCharMenus) {
						if (array[0] == PlayState.SONG.song.toLowerCase()) {
							notChosen = false;
							switch (array[1]) {
								case 0:
									LoadingState.loadAndSwitchState(new CharacterMenu(['bf', 'gf', 'enemy']));
								case 1:
									LoadingState.loadAndSwitchState(new CharacterMenu(['bf', 'gf']));
								case 2:
									LoadingState.loadAndSwitchState(new CharacterMenu(['bf', 'enemy']));
								case 3:
									LoadingState.loadAndSwitchState(new CharacterMenu(['gf', 'enemy']));
								case 4:
									LoadingState.loadAndSwitchState(new CharacterMenu(['bf']));
								case 5:
									LoadingState.loadAndSwitchState(new CharacterMenu(['gf']));
								case 6:
									LoadingState.loadAndSwitchState(new CharacterMenu(['enemy']));
							}
						}
					}
					if (notChosen == true) {
						LoadingState.loadAndSwitchState(new CharacterMenu(null));
					}
				case "Exit to menu":
					#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					if (PlayState.SONG.song.toLowerCase() == 'test') {
						PlayState.fixNoteskinAfterTestSongFinishes();
					}

					Mods.loadTopMod();
					if(PlayState.isStoryMode)
						MusicBeatState.switchState(new StoryMenuState());
					else if (MainMenuState.codeEntered)
						MusicBeatState.switchState(new MainMenuState());
					else 
						MusicBeatState.switchState(new FreeplayState());

					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
					FlxG.camera.followLerp = 0;
			}
		}
	}

	function deleteSkipTimeText()
	{
		if(skipTimeText != null)
		{
			skipTimeText.kill();
			remove(skipTimeText);
			skipTimeText.destroy();
		}
		skipTimeText = null;
		skipTimeTracker = null;
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
		}
		MusicBeatState.resetState();
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;
	
		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;
	
		for (i in 0...grpMenuShit.members.length)
		{
			grpMenuShit.members[i].alpha = 0.6;
		}
		grpMenuShit.members[curSelected].alpha = 1;
	
		if(grpMenuShit.members[curSelected] == skipTimeTracker)
		{
			curTime = Math.max(0, Conductor.songPosition);
			updateSkipTimeText();
		}
	
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	
		missingText.visible = false;
		missingTextBG.visible = false;
	
	}
	
	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			var obj = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		var spacing:Float = 40; // Adjust this value to change the spacing
		var totalHeight:Float = menuItems.length * spacing;
		var startY:Float = ((FlxG.height - totalHeight) / 2) + 235;
		if(PlayState.chartingMode)
		{
			startY = ((FlxG.height - totalHeight) / 2) + 100;
		}
		
		for (i in 0...menuItems.length) {
			var item = new FlxText(20, startY + (i * spacing), 0, menuItems[i]);
			item.setFormat(Paths.font(PlayState.isPixelStage ? "pixel.otf" : "PhantomMuff.ttf"), PlayState.isPixelStage ? 25 : 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			item.scrollFactor.set();
			grpMenuShit.add(item);

			if(menuItems[i] == 'Skip Time')
			{
				skipTimeText = new FlxText(0, 0, 0, '', 64);
				skipTimeText.setFormat(Paths.font(PlayState.isPixelStage ? "pixel.otf" : "PhantomMuff.ttf"), PlayState.isPixelStage ? 25 : 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				skipTimeText.scrollFactor.set();
				skipTimeText.borderSize = 2;
				skipTimeTracker = item;
				add(skipTimeText);

				updateSkipTextStuff();
				updateSkipTimeText();
			}
		}
		
		curSelected = 0;
		changeSelection();
	}

	function firstRegenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			var obj = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		var spacing:Float = 40; // Adjust this value to change the spacing
		var totalHeight:Float = menuItems.length * spacing;
		var startY:Float = ((FlxG.height - totalHeight) / 2) + 235;
		if(PlayState.chartingMode)
		{
			startY = ((FlxG.height - totalHeight) / 2) + 100;
		}
		
		for (i in 0...menuItems.length) {
			var item = new FlxText(20, startY + (i * spacing) + 500, 0, menuItems[i]);
			item.setFormat(Paths.font(PlayState.isPixelStage ? "pixel.otf" : "PhantomMuff.ttf"), PlayState.isPixelStage ? 25 : 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			item.scrollFactor.set();
			grpMenuShit.add(item);
			FlxTween.tween(item, {y: startY + (i * spacing)}, 0.5, {ease: FlxEase.sineOut});

			if(menuItems[i] == 'Skip Time')
			{
				skipTimeText = new FlxText(0, 0, 0, '', 64);
				skipTimeText.setFormat(Paths.font(PlayState.isPixelStage ? "pixel.otf" : "PhantomMuff.ttf"), PlayState.isPixelStage ? 25 : 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				skipTimeText.scrollFactor.set();
				skipTimeText.borderSize = 2;
				skipTimeTracker = item;
				add(skipTimeText);

				updateSkipTextStuff();
				updateSkipTimeText();
			}
		}
		
		curSelected = 0;
		changeSelection();
	}
	
	function updateSkipTextStuff()
	{
		if(skipTimeText == null || skipTimeTracker == null) return;

		skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
		skipTimeText.y = skipTimeTracker.y + 50;
		skipTimeText.visible = (skipTimeTracker.alpha >= 1);
	}

	function updateSkipTimeText()
	{
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false) + ' / ' + FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
	}
}
