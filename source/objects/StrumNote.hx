package objects;

import backend.animation.PsychAnimationController;

import shaders.RGBPalette;
import shaders.RGBPalette.RGBShaderReference;

class StrumNote extends FlxSprite
{
	public var rgbShader:RGBShaderReference;
	public var resetAnim:Float = 0;
	public var noteData:Int = 0;
	public var direction:Float = 90;//plan on doing scroll directions soon -bb
	public var downScroll:Bool = false;//plan on doing scroll directions soon -bb
	public var sustainReduce:Bool = true;
	private var player:Int;
	
	public var texture(default, set):String = null;
	private function set_texture(value:String):String {
		if(texture != value) {
			texture = value;
			reloadNote();
		}
		return value;
	}
	// Torch - This is for custom Note Styles per character
	public var notefolder(default, set):String = null;
	private function set_notefolder(value:String):String {
		if(notefolder != value) {		
			notefolder = value;
		}
		return value;
	}

	public var useRGBShader:Bool = true;
	public function new(x:Float, y:Float, leData:Int, player:Int, ?assets:String, ?path:String) {
		animation = new PsychAnimationController(this);

		rgbShader = new RGBShaderReference(this, Note.initializeGlobalRGBShader(leData));
		rgbShader.enabled = false;
		if(PlayState.SONG != null && PlayState.SONG.disableNoteRGB) useRGBShader = false;
		
		var arr:Array<FlxColor> = ClientPrefs.data.arrowRGB[leData];
		if(PlayState.isPixelStage) arr = ClientPrefs.data.arrowRGBPixel[leData];
		
		if(leData <= arr.length)
		{
			@:bypassAccessor
			{
				rgbShader.r = arr[0];
				rgbShader.g = arr[1];
				rgbShader.b = arr[2];
			}
		}

		noteData = leData;
		this.player = player;
		this.noteData = leData;
		super(x, y);

		var skin:String = null;

		if (path != null && assets != null) {
			skin = assets;
			notefolder = path;
		} else if (path == null && assets != null) {
			notefolder = 'torchs_assets';
			skin = assets;
		} else if (assets == null && path != null) {
			skin = 'custom_notes/normal';
			notefolder = path;
		} else if (PlayState.SONG != null && PlayState.SONG.arrowSkin != null && PlayState.SONG.arrowSkin.length > 1) {
			skin = PlayState.SONG.arrowSkin;
			notefolder = 'shared';
		} else {
			skin = Note.defaultNoteSkin;
			notefolder = 'shared';
		} 
		var customSkin:String = skin + Note.getNoteSkinPostfix();
		if(Paths.fileExists('images/$customSkin.png', IMAGE, true, notefolder)) skin = customSkin;

		texture = skin; //Load texture and anims
		scrollFactor.set();
	}

	function altSkin(?assets:String = ''):String {
		var tableOfSkins:Array<String> = [
			'custom_notes/parents'
		];

		for (skin in tableOfSkins) {
			if (assets.startsWith(skin)) {
				return '-alt';
			}
		}
		return '0';
	}

	public function reloadNote()
	{
		var lastAnim:String = null;
		if(animation.curAnim != null) lastAnim = animation.curAnim.name;

		var pixelPath:String = PlayState.isPixelStage ? 'pixelUI/' : '';

		// Failsafe
		if (texture.startsWith('custom_notes/') && !Paths.fileExists('images/' + pixelPath + texture + '.png', IMAGE, true, notefolder)) {
			if (pixelPath == 'pixelUI/' && texture.startsWith('custom_notes/')) pixelPath = '';
			
			if (!Paths.fileExists('images/' + pixelPath + texture + '.png', IMAGE, true, notefolder)) {
				if (texture.startsWith('custom_notes/pixelUI/')) {
					texture = 'custom_notes/pixelUI/normal';
				} else {
					texture = 'custom_notes/normal';
				}
			}
		}

		if(PlayState.isPixelStage || texture.startsWith('custom_notes/pixelUI/'))
		{
			loadGraphic(Paths.image(pixelPath + texture, notefolder));
			width = width / 4;
			height = height / 5;
			loadGraphic(Paths.image(pixelPath + texture, notefolder), true, Math.floor(width), Math.floor(height));

			antialiasing = false;
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));

			animation.add('green', [6]);
			animation.add('red', [7]);
			animation.add('blue', [5]);
			animation.add('purple', [4]);
			switch (Math.abs(noteData) % 4)
			{
				case 0:
					animation.add('static', [0]);
					animation.add('pressed', [4, 8], 12, false);
					animation.add('confirm', [12, 16], 24, false);
				case 1:
					animation.add('static', [1]);
					animation.add('pressed', [5, 9], 12, false);
					animation.add('confirm', [13, 17], 24, false);
				case 2:
					animation.add('static', [2]);
					animation.add('pressed', [6, 10], 12, false);
					animation.add('confirm', [14, 18], 12, false);
				case 3:
					animation.add('static', [3]);
					animation.add('pressed', [7, 11], 12, false);
					animation.add('confirm', [15, 19], 24, false);
			}
		}
		else
		{
			frames = Paths.getSparrowAtlas(texture, notefolder);
			animation.addByPrefix('green', 'arrowUP');
			animation.addByPrefix('blue', 'arrowDOWN');
			animation.addByPrefix('purple', 'arrowLEFT');
			animation.addByPrefix('red', 'arrowRIGHT');

			antialiasing = ClientPrefs.data.antialiasing;
			setGraphicSize(Std.int(width * 0.7));

			switch (Math.abs(noteData) % 4)
			{
				case 0:
					animation.addByPrefix('static', 'arrowLEFT');
					animation.addByPrefix('pressed', 'left press0', 24, false);
					animation.addByPrefix('confirm', 'left confirm0', 24, false);
					animation.addByPrefix('pressed-alt', 'left press' + altSkin(texture), 24, false);
					animation.addByPrefix('confirm-alt', 'left confirm' + altSkin(texture), 24, false);
				case 1:
					animation.addByPrefix('static', 'arrowDOWN');
					animation.addByPrefix('pressed', 'down press0', 24, false);
					animation.addByPrefix('confirm', 'down confirm0', 24, false);
					animation.addByPrefix('pressed-alt', 'down press' + altSkin(texture), 24, false);
					animation.addByPrefix('confirm-alt', 'down confirm' + altSkin(texture), 24, false);
				case 2:
					animation.addByPrefix('static', 'arrowUP');
					animation.addByPrefix('pressed', 'up press0', 24, false);
					animation.addByPrefix('confirm', 'up confirm0', 24, false);
					animation.addByPrefix('pressed-alt', 'up press' + altSkin(texture), 24, false);
					animation.addByPrefix('confirm-alt', 'up confirm' + altSkin(texture), 24, false);
				case 3:
					animation.addByPrefix('static', 'arrowRIGHT');
					animation.addByPrefix('pressed', 'right press0', 24, false);
					animation.addByPrefix('confirm', 'right confirm0', 24, false);
					animation.addByPrefix('pressed-alt', 'right press' + altSkin(texture), 24, false);
					animation.addByPrefix('confirm-alt', 'right confirm' + altSkin(texture), 24, false);
			}
		}
		updateHitbox();

		if(lastAnim != null)
		{
			playAnim(lastAnim, true);
		}
	}

	public function postAddedToGroup() {
		playAnim('static');
		x += Note.swagWidth * noteData;
		x += 50;
		x += ((FlxG.width / 2) * player);
		ID = noteData;
	}

	override function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}
		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		if(animation.curAnim != null)
		{
			centerOffsets();
			centerOrigin();
		}
		if(useRGBShader) rgbShader.enabled = (animation.curAnim != null && animation.curAnim.name != 'static');
	}
}
