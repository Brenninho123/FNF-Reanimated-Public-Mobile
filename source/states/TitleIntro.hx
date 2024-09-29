package states;

//Yeah i know i could do this on titlestate but im to lazy to move shit :p

import states.TitleState;
import openfl.Assets;
import flixel.input.mouse.FlxMouse;
import flixel.input.mouse.FlxMouseEventManager;
import openfl.ui.Mouse;
import torchsthings.shaders.CRT;
import openfl.filters.ShaderFilter;

#if VIDEOS_ALLOWED
#if (hxCodec >= "3.0.0") import hxcodec.flixel.FlxVideo as VideoHandler;
#elseif (hxCodec >= "2.6.1") import hxcodec.VideoHandler as VideoHandler;
#elseif (hxCodec == "2.6.0") import VideoHandler;
#else import vlc.MP4Handler as VideoHandler; #end
#end


class TitleIntro extends MusicBeatState
{
	var crt:CRT = new CRT();
    public var jesus:Bool = true;
    private var video:VideoHandler;
    override function create()
    {
        FlxG.mouse.visible = false;

		FlxG.game.setFilters([new ShaderFilter(crt)]);

        super.create();
    }


    //video started on update cuz on create aint work
    override function update(elapsed:Float)
    {
        if (jesus)
        {
            startVideo("Colab X 17 buck Colifloor");
            jesus = false;
        }

        if (FlxG.keys.justPressed.ENTER) {
            endVideo();
        }
		crt.update(elapsed);

        super.update(elapsed);
    }

    public function startVideo(name:String)
    {
        #if VIDEOS_ALLOWED
        
        var filepath:String = Paths.video(name);
        #if sys
        if(!FileSystem.exists(filepath))
        #else
        if(!OpenFlAssets.exists(filepath))
        #end
        {
            FlxG.log.warn('Couldnt find video file: ' + name);
            MusicBeatState.switchState(new TitleState());
            return;
        }

        video = new VideoHandler();
        #if (hxCodec >= "3.0.0")
        // Recent versions
        video.play(filepath);
        video.onEndReached.add(endVideo, true);
        #else
        // Older versions
        video.playVideo(filepath);
        video.finishCallback = endVideo();
        #end
        #else
        FlxG.log.warn('Platform not supported!');
        MusicBeatState.switchState(new TitleState());
        #end
    } 
    
    function endVideo(){
        #if (hxCodec >= "3.0.0")
        video.dispose();
        #end

        FlxG.game.setFilters(null);

        MusicBeatState.switchState(new TitleState());
    }
}