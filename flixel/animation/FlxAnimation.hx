package flixel.animation;
import flixel.FlxG;
import flixel.FlxSprite;

/**
 * Just a helper structure for the FlxSprite animation system.
 */
class FlxAnimation extends FlxBaseAnimation
{
	/**
	 * A list of frames stored as <code>int</code> objects
	 */
	public var frames:Array<Int>;
	
	/**
	 * Accesor for frames.length
	 */
	public var numFrames(get, null):Int;
	
	/**
	 * Animation frameRate - the speed in frames per second that the animation should play at.
	 */
	public var frameRate(default, set):Int;
	
	/**
	 * Keeps track of the current frame of animation.
	 * This is NOT an index into the tile sheet, but the frame number in the animation object.
	 */
	public var curFrame(default, set):Int = 0;
	
	/**
	 * Whether the current animation has finished its first (or only) loop.
	 */
	public var finished(default, null):Bool;
	
	/**
	 * Seconds between frames (basically the framerate)
	 */
	public var delay(default, null):Float;
	
	/**
	 * Whether the current animation gets updated or not.
	 */
	public var paused:Bool;
	
	/**
	 * Whether or not the animation is looped
	 */
	public var looped:Bool;
	
	/**
	 * Internal, used to time each frame of animation.
	 */
	private var _frameTimer:Float;
	
	/**
	 * Constructor
	 * @param	Name		What this animation should be called (e.g. "run")
	 * @param	Frames		An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3)
	 * @param	FrameRate	The speed in frames per second that the animation should play at (e.g. 40)
	 * @param	Looped		Whether or not the animation is looped or just plays once
	 */
	public function new(Parent:FlxAnimationController, Name:String, Frames:Array<Int>, FrameRate:Int = 0, Looped:Bool = true)
	{
		super(Parent, Name);
		
		frameRate = FrameRate;
		frames = Frames;
		looped = Looped;
		finished = true;
		paused = true;
		curFrame = 0;
		frameIndex = 0;
		_frameTimer = 0;
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		frames = null;
		name = null;
		super.destroy();
	}
	
	public function play(Force:Bool = false, Frame:Int = 0):Void
	{
		if (!Force && (looped || !finished))
		{
			paused = false;
			finished = false;
			curFrame = curFrame;
			return;
		}
		
		paused = false;
		finished = false;
		_frameTimer = 0;
		
		if (Frame < 0)
		{
			curFrame = Std.int(Math.random() * frames.length);
		}
		else if (frames.length > Frame)
		{
			curFrame = Frame;
		}
		else
		{
			curFrame = 0;
		}
		
		if (delay <= 0)
		{
			finished = true;
		}
		else
		{
			finished = false;
		}
	}
	
	public function restart():Void
	{
		play(true);
	}
	
	public function stop():Void
	{
		finished = true;
		paused = true;
	}
	
	override public function update():Void
	{
		if (delay > 0 && (looped || !finished) && !paused)
		{
			_frameTimer += FlxG.elapsed;
			while (_frameTimer > delay)
			{
				_frameTimer = _frameTimer - delay;
				curFrame++;
			}
		}
	}
	
	private function set_frameRate(value:Int):Int
	{
		delay = 0;
		frameRate = value;
		if (value > 0)
		{
			delay = 1.0 / value;
		}
		return value;
	}
	
	inline private function get_numFrames():Int
	{
		return frames.length;
	}
	
	private function set_curFrame(Frame:Int):Int
	{
		var num:Int = frames.length;
		
		if (Frame >= 0 && Frame < num)
		{
			curFrame = Frame;
			if (curFrame == num - 1)
			{
				if (looped)
				{
					curFrame = 0;
				}
				else
				{
					finished = true;
				}
			}
		}
		else if (Frame < 0)
		{
			curFrame = Std.int(Math.random() * frames.length);
		}
		
		frameIndex = frames[curFrame];
		return Frame;
	}
	
	override public function clone(Parent:FlxAnimationController):FlxAnimation
	{
		return new FlxAnimation(Parent, name, frames, frameRate, looped);
	}
}