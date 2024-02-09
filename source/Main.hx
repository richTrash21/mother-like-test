package;

import openfl.text.TextField;
import haxe.PosInfos;

class Main // extends openfl.display.Sprite
{
	#if SHOW_FPS
	@:allow(Game)
	public static var fps(default, null):debug.FPS;
	#end

	// idk but its kinda cool to lock game creation to the only class that can make it :trollface:
	// @:allow(ApplicationMain)
	static function main()
	{
		openfl.Lib.application.window.stage.addChild(new Game(Init, 60/*, 60, true*/));
		#if flixel_studio
		flixel.addons.studio.FlxStudio.create();
		#end
	}

	/*public function new()
	{
		super();
		addChild(new Game(#if flash 640, 480, #end Init, 60, 60, true));
		// FlxG.game.addChild(fps = new debug.FPS());
	}*/
}

private class Game extends flixel.FlxGame
{
	// undertale
	#if sys
	@:noCompletion var _exit:TextField;
	#end

	#if debug
	static var _logTimeout = 5.;
	static var _logLen = 40;

	var _logText:TextField;
	var _log:Array<LogEntry>;
	#end
	var _fullLog = "";

	public function new(gameWidth = 0, gameHeight = 0, ?initialState:Class<flixel.FlxState>, fps = 60)
	{
		#if debug
		_log = [for (i in 0..._logLen) new LogEntry("", _logTimeout)];
		#end

		haxe.Log.trace = (v:Dynamic, ?pos:PosInfos) ->
		{
			// based on haxe.Log.formatOutput()
			inline function formatOutput(v:Dynamic, pos:PosInfos):String
			{
				final t = "<" + Date.now().toString().substr(11, 8) + ">";
				var s = " > " + Std.string(v);
				if (pos == null)
					return t + s;
				var p = pos.fileName + ":" + pos.lineNumber;
				if (pos.methodName != null && pos.methodName.length > 0)
				{
					final t = pos.className != null && pos.className.length > 0 ? pos.className + "." + pos.methodName : pos.methodName;
					p += " - " + t + "()";
				}
				if (pos.customParams != null)
					for (v in pos.customParams)
						s += ", " + Std.string(v);
				return t + " [" + p + "]" + s;
			}

			final str = formatOutput(v, pos);
			_fullLog += str + "\n";
			#if debug
			// if (_log != null)
				_log.unshift(_log.pop().set(str, pos));
			#end

			// vanilla trace
			#if js
			if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null)
				(untyped console).log(str);
			#elseif lua
			untyped __define_feature__("use._hx_print", _hx_print(str));
			#elseif sys
			Sys.println(str);
			#else
			throw new haxe.exceptions.NotImplementedException()
			#end
		}

		super(gameWidth, gameHeight, initialState, fps, fps, true);
	}

	override function create(e)
	{
		// TODO: custom sound tray
		// _customSoundTray = 
		super.create(e);
		// TODO: make log saving
		stage.window.onClose.add(haxe.Log.trace.bind(Date.now()));

		#if sys
		// undertale
		_exit = new TextField();
		_exit.defaultTextFormat = new openfl.text.TextFormat(Assets.font("sans") /* SAAAAANS */, 24, 0xFFFFFF, true);
		_exit.selectable = _exit.mouseEnabled = _exit.mouseWheelEnabled = false;
		_exit.autoSize = LEFT;
		_exit.alpha = 0;
		addChild(_exit);
		_exit.x = 2;
		#end

		#if SHOW_FPS
		addChild(Main.fps = new debug.FPS());
		#end

		#if debug
		_logText = new TextField();
		_logText.defaultTextFormat = new openfl.text.TextFormat("_sans", 10, 0xFFFFFF, true);
		_logText.selectable = _logText.mouseEnabled = _logText.mouseWheelEnabled = false;
		_logText.multiline = _logText.wordWrap = true;
		_logText.autoSize = LEFT;
		_logText.width = 400;
		addChild(_logText);
		_logText.x = 10;
		_logText.y = 50;

		_logText.shader = new shaders.Outline.OutlineShader(1.25);

		FlxG.console.registerFunction("clearGameLog", () ->
		{
			_logText.text = "";
			for (entry in _log)
				entry.time = _logTimeout;
		}
		);
		#end

		// stolen shader coord fix :trollface:
		FlxG.signals.gameResized.add((w, h) ->
		{
			// @:access(openfl.display.BitmapData)
			inline function resetSpriteCache(sprite:openfl.display.Sprite)
			{
				/*if (sprite.__cacheBitmap != null)
				{
					sprite.__cacheBitmap.__cleanup();
					sprite.__cacheBitmap = null;
				}
		
				if (sprite.__cacheBitmapData != null)
				{
					sprite.__cacheBitmapData.dispose();
					sprite.__cacheBitmapData = null;
				}*/
				sprite.__cleanup();
			}

			if (FlxG.cameras.list.length == 1 && FlxG.camera.filters != null && FlxG.camera.filters.length > 0)
				resetSpriteCache(FlxG.camera.flashSprite);
			else
				for (camera in FlxG.cameras.list)
					if (camera.filters != null && camera.filters.length > 0)
						resetSpriteCache(camera.flashSprite);

			if (this.filters != null && this.filters.length > 0)
				resetSpriteCache(this);

			#if sys
			_exit.scaleX = FlxG.scaleMode.scale.x;
			_exit.scaleY = FlxG.scaleMode.scale.y;
			_exit.y = FlxG.scaleMode.gameSize.y - 28 * _exit.scaleY;
			#end

			#if debug
			// _logLen = Math.ceil((h - _logText.y) / 12);
			#end
		});
	}

	#if debug
	// @:noCompletion var __log__timeout = 0.;
	#end

	override function step()
	{
		super.step();

		#if debug
		// __log__timeout += FlxG.elapsed;
		// if (__log__timeout >= 1) // update log every second instead of each step() call
		// {
			updateLog(FlxG.elapsed);
			// __log__timeout = 0;
		// }
		#end

		#if sys
		undertale(FlxG.elapsed);
		#end
	}

	#if debug
	@:noCompletion function updateLog(e:Float)
	{
		var str = "";
		var entry:LogEntry;
		for (i in 0..._logLen)
		{
			entry = _log[i];
			if (entry == null || entry.time > _logTimeout)
				continue;

			entry.time += e;
			if (entry.time < _logTimeout && entry.text.length > 0)
				str += entry.text + "\n";
		}
		_logText.text = str;
	}
	#end

	@:noCompletion var __exit__timer = 0.;

	#if sys
	/**  Undertale  **/
	@:noCompletion /*inline*/ function undertale(e:Float)
	{
		final a = FlxG.keys.pressed.ESCAPE ? e : -e;
		if (_exit.alpha == 0 && a < 0)
			return;

		_exit.alpha += a;

		final dots = _exit.alpha < .4 ? "." : _exit.alpha < .6 ? ".." : _exit.alpha < .8 ? "..." : "....";
		_exit.text = "EXITING" + dots;

		if (_exit.alpha == 1.)
		{
			__exit__timer += e;
			if (__exit__timer > .3) Sys.exit(0);
		}
		else
			__exit__timer = 0.;
	}
	#end
}

#if debug
private final class LogEntry
{
	public var text:String;
	public var time:Float;
	public var pos:PosInfos;

	public function new(text:String, time = 0.):Void
	{
		// trace("new LogEntry");
		this.set(text, time);
	}

	inline public function set(text:String, time = 0., ?pos:PosInfos):LogEntry
	{
		this.text = text;
		this.time = time;
		this.pos = pos;
		return this;
	}

	public function toString():String
	{
		var s = text;
		if (pos?.customParams != null)
			for (v in pos.customParams)
				s += ", " + Std.string(v);
		return s;
	}
}
#end
