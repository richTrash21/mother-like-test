package debug;

#if SHOW_FPS
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPS extends openfl.text.TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	/**
		The current garbage collector memory usage (does not work on html5)
	**/
	public var memory(get, never):Int;

	@:noCompletion var cacheCount:Int;
	@:noCompletion var currentTime:Int;
	@:noCompletion var times:Array<Int>;

	public function new(x = 10., y = 10., color = 0xFFFFFF)
	{
		super();

		this.x = x;
		this.y = y;

		defaultTextFormat = new openfl.text.TextFormat("_sans", 12, color);
		selectable = mouseEnabled = mouseWheelEnabled = false;
		autoSize = LEFT;
		text = "FPS: ";

		currentFPS = currentTime = cacheCount = 0;
		times = [];

		shader = new shaders.Outline.OutlineShader(2);

		#if flash
		addEventListener(openfl.events.Event.ENTER_FRAME, (e) ->
		{
			final time = openfl.Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
	}

	// Event Handlers
	@:noCompletion #if !flash override #end function __enterFrame(deltaTime:Int):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);
		while (times[0] < currentTime - 1000) times.shift();

		final currentCount = times.length;
		if (currentCount != cacheCount /*&& visible*/)
		{
			final newFPS = Std.int((currentCount + cacheCount) * .5);
			// caping new framerate to the maximum fps possible so it wont go above
			currentFPS = newFPS > FlxG.updateFramerate ? FlxG.updateFramerate : newFPS;
			cacheCount = currentCount;
		}

		text = "FPS: " + currentFPS;

		#if !html5 // doesn't work on browser
		text += "\nMemory: " + flixel.util.FlxStringUtil.formatBytes(memory);
		#end

		#if (gl_stats && !disable_cffi && (!html5 || !canvas))
		text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
		text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
		text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
		#end
	}

	@:noCompletion inline function get_memory():Int
	{
		#if html5
		throw "Can't get memory usage, since you are on browser target!";
		#else
		return #if cpp cast(openfl.system.System.totalMemory, UInt) #else openfl.system.System.totalMemory #end;
		#end
	}
}
#end
