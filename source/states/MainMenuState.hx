package states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.input.mouse.FlxMouse;
import flixel.input.mouse.FlxMouseEventManager;
import states.editors.MasterEditorMenu;
import options.OptionsState;
import flixel.input.keyboard.FlxKey;
import flixel.input.FlxKeyManager;
import backend.Highscore;
import backend.Song;
import states.PlayState;
import openfl.ui.Mouse;

import torchsfunctions.functions.KeyboardTools;

class MainMenuState extends MusicBeatState
{
	public static var fnfReaniV:String = 'Beta 1.0';
	public static var psychEngineVersion:String = '0.7.3'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public static var codeEntered:Bool = false; // Just for some detection is all, like for the "debugger" achievement

	var menuItems:FlxTypedGroup<FlxSprite>;
	
	var charInput:String = "";
	var codesAndSongs:Array<Array<String>> = [
		["SMASH", "Verbal-smash"], 
		["CHUDNELL", "score"], 
		["TMG", "high-remix"], 
		["HEV", "pico-erect"], 
		["KARANXD", "blammed-erect"], 
		["LOCKIN", "fuck-you"],
		["DUPLEX", "blammed-remix"],
		//["ICONOCLAST", "robin"],
		["HENRY", "cg5"],
		//["BFMIX", "Darnell-bf-mix"],
		["DEBUG", 'test']
	];
	var invalidCodes:Array<String> = [];
	var mouseCords:FlxText;

	var optionShit:Array<String> = [
		//'aaa', //Don't even need
		'story_mode', //0
		//#if MODS_ALLOWED 'mods', #end
		#if ACHIEVEMENTS_ALLOWED 'awards', #end // 1
		'credits', // 2
		//#if !switch 'donate', #end
		'options', // 3
		'freeplay', // 4
		'nothing' // 5
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	var djData:Array<Array<String>> = [
	//	['djAssetName', 'x', 'y', 'graphicScale', 'djIdle', 'selectedAnimation'],
		['tutututurutututru', '660', '190', '0.6', 'bfeando ando0', ''], 
		['Jeys_BF_DJ_Assets', '380', '100', '0.8', 'BF Dancing Beat0', 'BF Cheer0'],
		['Boyfriend_DJ_original', '680', '200', '1.2', 'Boyfriend DJ0', 'Boyfriend hey0']
	];
	var randomDJnum:Int;
	var dj:BGSprite;

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		FlxG.mouse.visible = true;
		
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG/menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 0.68));
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = 0xfffdf24e;
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x73FFFFFF, 0x0));
		grid.velocity.set(-40, 40);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(grid);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuBG/menuDesat'));
		magenta.antialiasing = ClientPrefs.data.antialiasing;
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 0.68));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.color = 0xfffd4e82;
		magenta.visible = false;
		add(magenta);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x73FFFFFF, 0x0));
		grid.velocity.set(-40, 40);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(grid);

		randomDJnum = FlxG.random.int(0, djData.length - 1);
		var djName:String = djData[randomDJnum][0];
		var djOffsets:Array<Int> = [Std.parseInt(djData[randomDJnum][1]), Std.parseInt(djData[randomDJnum][2])];
		var djScale:Float = Std.parseFloat(djData[randomDJnum][3]);
		var djAnims:Array<String> = [djData[randomDJnum][4], djData[randomDJnum][5]];
		
		dj = new BGSprite('menuDJs/' + djName, djOffsets[0], djOffsets[1], 0.3, 0.3, [djAnims[0]], true);
		dj.animation.addByPrefix(djAnims[1], djAnims[1], 24, false);
		dj.antialiasing = ClientPrefs.data.antialiasing;
		dj.setGraphicSize(Std.int(dj.width * djScale));
		dj.updateHitbox();
		add(dj);

		/*mouseCords = new FlxText(20, 15 + 64, 0, "X: " + FlxG.mouse.x + "Y: " + FlxG.mouse.y, 32);
		mouseCords.scrollFactor.set();
		mouseCords.x = 0;
		mouseCords.y = 0;
		mouseCords.setFormat(Paths.font('vcr.ttf'), 32);
		mouseCords.updateHitbox();
		mouseCords.visible = true;
		add(mouseCords);
		*/
		
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);
		
		for (i in 0...optionShit.length)
		{
			if (optionShit[i] == 'nothing') {continue;}
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140) + offset);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if (optionShit.length < 6)
				scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.setGraphicSize(Std.int(menuItem.width * 0.7));
			menuItem.updateHitbox();
			//menuItem.screenCenter(X);
		
			switch (i)
			{
				case 0: 
					menuItem.x = 99.4;
					menuItem.y = 64.95;
				case 1:
					menuItem.x = 100;
					menuItem.y = 203;
				case 2:
					menuItem.x = 100;
					menuItem.y = 380;
				case 3:
					menuItem.x = 100;
					menuItem.y = 580;
				case 4:
					menuItem.x = 710.8;
					menuItem.y = 53.75;
			}
		}

		var rVer:FlxText = new FlxText(12, FlxG.height - 64, 0, "Reanimated " + fnfReaniV, 12);
		rVer.scrollFactor.set();
		rVer.setFormat("PhantomMuff.ttf", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(rVer);
		var psychVer:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		psychVer.scrollFactor.set();
		psychVer.setFormat("PhantomMuff.ttf", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(psychVer);
		var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat("PhantomMuff.ttf", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);
		changeItem(5);

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end

		super.create();

		//FlxG.camera.follow(camFollow, null, 6);
		Difficulty.resetList();
		codeEntered = false;
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P) {
				if (curSelected - 1 < 0 || curSelected == 5) changeItem(4);
				else if (curSelected <= 4) changeItem(curSelected - 1);
			}

			if (controls.UI_DOWN_P) {
				if (curSelected + 1 > 4) changeItem(0);
				else if (curSelected >= 0) changeItem(curSelected + 1);
			}

			if (controls.UI_RIGHT_P) {
				if (curSelected >= 4)
					changeItem(0);
				else changeItem(4);
			}
			if (controls.UI_LEFT_P) {
				if (curSelected >= 0 && curSelected < 4 || curSelected == 5)
					changeItem(4);
				else changeItem(0);
			}

			//Solucion bien chafa pero no me iba a poner a hacer mates :vvv
			/*if (controls.UI_LEFT_P && curSelected != optionShit.length - 1)
			{	
				changeItem(-1);
			}
			else if (controls.UI_LEFT_P && curSelected == optionShit.length - 1)
			{
				changeItem(optionShit.length);
			}
			*/	

			//trace(optionShit.length);

			if (CoolUtil.isMouseWithinBounds(FlxG.mouse.x, FlxG.mouse.y, 100, 65, 530, 140)) {
				changeItem(0);
			} else if (CoolUtil.isMouseWithinBounds(FlxG.mouse.x, FlxG.mouse.y, 90, 200, 395, 270)) {
				changeItem(1);
			} else if (CoolUtil.isMouseWithinBounds(FlxG.mouse.x, FlxG.mouse.y, 100, 372, 428, 450)) {
				changeItem(2);
			} else if (CoolUtil.isMouseWithinBounds(FlxG.mouse.x, FlxG.mouse.y, 100, 580, 440, 640)) {
				changeItem(3);
			} else if (CoolUtil.isMouseWithinBounds(FlxG.mouse.x, FlxG.mouse.y, 702, 58, 1045, 125)) {
				changeItem(4);
			} else if (FlxG.mouse.justMoved) {
				changeItem(5);
			}
	
			//mouseCords.text = "X: " + FlxG.mouse.x + "Y: " + FlxG.mouse.y;

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (FlxG.mouse.justPressed || controls.ACCEPT) {
				if (curSelected == 5) return;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				if (optionShit[curSelected] == 'donate') {
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				} else {
					selectedSomethin = true;

					var djCheer:String = djData[randomDJnum][5];
					dj.animation.play(djCheer);

					if (ClientPrefs.data.flashing)
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					FlxFlicker.flicker(menuItems.members[curSelected], 1, 0.06, false, false, function(flick:FlxFlicker) {
						FlxG.mouse.visible = false;
						switch (optionShit[curSelected]) {
							case 'story_mode':
								MusicBeatState.switchState(new StoryMenuState());

							#if ACHIEVEMENTS_ALLOWED
							case 'awards':
								MusicBeatState.switchState(new AchievementsMenuState());
							#end

							case 'credits':
								MusicBeatState.switchState(new CreditsState());
							case 'options':
								MusicBeatState.switchState(new OptionsState());
								OptionsState.onPlayState = false;
								if (PlayState.SONG != null) {
									PlayState.SONG.arrowSkin = null;
									PlayState.SONG.splashSkin = null;
									PlayState.stageUI = 'normal';
								}
							case 'freeplay':
								MusicBeatState.switchState(new FreeplayState());
						}
					});

					for (i in 0...menuItems.members.length) {
						if (i == curSelected) continue;
						FlxTween.tween(menuItems.members[i], {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween) {menuItems.members[i].kill();}
						});
					}
				}
			}

			#if MODS_ALLOWED
			if (FlxG.keys.justPressed.NINE) { // No direct option, but still available for peeps
				trace('opening mod browser');
				MusicBeatState.switchState(new ModsMenuState());
			}
			#end

			if (FlxG.keys.justPressed.EIGHT) { // No direct option, but still available for peeps
				if (Achievements.achievementsUnlocked.contains('debugger')) {
					Achievements.achievementsUnlocked.remove('debugger');
					Achievements.save();
					trace('debugger removed');
				}
			}

			#if desktop
			if (controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end

			charInput += KeyboardTools.keypressToString();
			for (array in codesAndSongs) {
				if (array[0].toUpperCase().trim().startsWith(charInput)) {
					if (charInput == array[0].toUpperCase().trim() && !invalidCodes.contains(array[0])) {
						FlxG.mouse.visible = false;
						selectedSomethin = true;
						codeEntered = true;

						FlxG.sound.play(Paths.sound('confirmMenu'));
						var djCheer:String = djData[randomDJnum][5];
						dj.animation.play(djCheer);

						var songLowercase:String = Paths.formatToSongPath(array[1]);
						var poop:String = Highscore.formatSong(songLowercase, 2);

						PlayState.SONG = Song.loadFromJson(poop, songLowercase);
						PlayState.isStoryMode = false;
						PlayState.storyDifficulty = 2;

						LoadingState.loadAndSwitchState(new PlayState());
					}
					continue;
				} else {
					if (invalidCodes.contains(array[0])) continue;
					invalidCodes.push(array[0]);
					//trace(invalidCodes);
				}
			}
			if (invalidCodes.length == codesAndSongs.length) {
				invalidCodes = [];
				charInput = '';
				//trace("reset char input");
			}
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		if (curSelected == huh)
			return;
		if (curSelected != 5) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
			menuItems.members[curSelected].animation.play('idle', true);
			menuItems.members[curSelected].updateHitbox();
		}
		
		curSelected = huh; 

		if (curSelected > menuItems.length )
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		if (curSelected != 5) {
			menuItems.members[curSelected].animation.play('selected');
			menuItems.members[curSelected].centerOffsets();
		}
	}
}