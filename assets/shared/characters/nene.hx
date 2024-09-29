import states.stages.objects.ABot;

var abot:ABot;
var abotLookDir:Bool = false;

final MIN_BLINK_DELAY:Int = 3;
final MAX_BLINK_DELAY:Int = 7;
final VULTURE_THRESHOLD:Float = 0.5;
var blinkCountdown:Int = 3;

var STATE_DEFAULT = 0;
var STATE_PRE_RAISE = 1;
var STATE_RAISE = 2;
var STATE_READY = 3;
var STATE_LOWER = 4;

var currentNeneState = STATE_DEFAULT;
var animationFinished:Bool = false;

function onCreate()
{
    abot = new ABot(gfGroup.x - 100, gfGroup.y + 330);
    addBehindGF(abot);
    updateABotEye(true);
}

function onCreatePost()
{
    if(gf != null)
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
}

function onSectionHit()
{
	updateABotEye();
}

function onSongStart()
{
    abot.setAudioSource(FlxG.sound.music);
    abot.startVisualizer();
    gf.animation.finishCallback = onNeneAnimationFinished;
}

function updateABotEye(?finishInstantly:Bool = false)
{
    if(PlayState.SONG.notes[Std.int(FlxMath.bound(curSection, 0, PlayState.SONG.notes.length - 1))].mustHitSection == true)
        abot.lookRight();
    else
        abot.lookLeft();

    if(finishInstantly) abot.eyes.anim.curFrame = abot.eyes.anim.length - 1;
    
}

function onUpdate(elapsed:Float)
{
    if(gf == null || !PlayState.instance.startedCountdown) return;

    animationFinished = gf.isAnimationFinished();
    transitionState();

    if (songName == "blazin")
    {
        abot.color = 0xFF888888;
    }
}

function transitionState() 
{
    switch (currentNeneState)
    {
        case STATE_DEFAULT:
            if (PlayState.instance.health <= VULTURE_THRESHOLD)
            {
                currentNeneState = STATE_PRE_RAISE;
                gf.skipDance = true;
            }

        case STATE_PRE_RAISE:
            if (PlayState.instance.health > VULTURE_THRESHOLD)
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
            if (PlayState.instance.health > VULTURE_THRESHOLD)
            {
                currentNeneState = STATE_LOWER;
                gf.specialAnim = true;
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
}

function onBeatHit()
{
    switch(currentNeneState) {
        case STATE_READY:
            if (blinkCountdown == 0)
            {
                gf.playAnim('idle-alt', false);
                blinkCountdown = FlxG.random.int(MIN_BLINK_DELAY, MAX_BLINK_DELAY);
            }
            else blinkCountdown--;

        default:
            // In other states, don't interrupt the existing animation.
    }
    abot.bop();
}
	
function onNeneAnimationFinished(name:String)
{
    if(!PlayState.instance.startedCountdown) return;

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
}

function goodNoteHit(note:Note)
{
	// 10% chance of playing comboCheer/comboCheerHigh animations for Nene
    if(FlxG.random.bool(10))
    {
        switch(game.combo)
        {
            case 50, 100:
                var animToPlay:String = 'combo${game.combo}';
                if(gf.animation.exists(animToPlay))
                {
                    gf.playAnim(animToPlay);
                    gf.specialAnim = true;
                }
        }
    }
}