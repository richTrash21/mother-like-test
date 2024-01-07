package debug;

#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end

#if flash
import haxe.Timer;
import openfl.Lib;
import openfl.events.Event;
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

	@:noCompletion private var memory(get, never):Int;
	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Int;
	@:noCompletion private var times:Array<Int>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new openfl.text.TextFormat("_sans", 12, color);
		text = "FPS: ";

		cacheCount = 0;
		currentTime = 0;
		times = [];

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
	}

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Int):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);
		while (times[0] < currentTime - 1000) times.shift();

		final currentCount = times.length;
		currentFPS = Std.int((currentCount + cacheCount) * 0.5);

		if (currentCount != cacheCount)
		{
			text = "FPS: " + currentFPS;
			text += "\nMemory: " + flixel.util.FlxStringUtil.formatBytes(memory);

			#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
			text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
			text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
			#end
		}

		cacheCount = currentCount;
	}

	inline function get_memory():Int
		return cast(openfl.system.System.totalMemory, UInt);
}
