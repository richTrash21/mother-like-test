package;

import flixel.util.typeLimit.NextState.InitialState;
import flixel.FlxState;

import openfl.text.TextField;

import haxe.PosInfos;

class Main
{
	#if SHOW_FPS
	@:allow(Game)
	public static var fps(default, null):debug.FPS;
	#end

	static function main()
	{
		openfl.Lib.application.window.stage.addChild(new Game(PlayState, 60/*, 60, true*/));
		#if flixel_studio
		flixel.addons.studio.FlxStudio.create();
		#end
	}
}

@:noCompletion private class Game extends flixel.FlxGame
{
	#if sys
	// undertale
	@:noCompletion var __exit:TextField;
	#end

	@:allow(LogEntry) inline static var __logTimeout = 5.;
	inline static var __logLen = 40;

	#if debug
	var __logDisplay:TextField;
	#end
	var __log:Array<LogEntry>;
	var LOG_FULL = "";

	public function new(gameWidth = 0, gameHeight = 0, ?initialState: #if (flixel >= "5.6.0") InitialState #else Class<FlxState> #end, fps = 60)
	{
		__log = [for (i in 0...__logLen) new LogEntry()];
		Init.__init = initialState;

		haxe.Log.trace = (v:Dynamic, ?pos:PosInfos) ->
		{
			// based on haxe.Log.formatOutput()
			inline function formatOutput(v:Dynamic, pos:PosInfos):String
			{
				/*final t = "<" + Date.now().toString().substr(11, 8) + ">";
				var s = " > " + v.string();
				if (pos == null)
					return t + s;
				var p = pos.fileName + ":" + pos.lineNumber;
				if (pos.methodName != null && pos.methodName.length > 0)
				{
					final t = pos.className != null && pos.className.length > 0 ? pos.className + "." + pos.methodName : pos.methodName;
					p += " - " + t + "()";
				}
				if (pos.customParams != null)
					for (_v in pos.customParams)
						s += ", " + _v.string();
				return t + " [" + p + "]" + s;*/
				var s = v.string();
				if (pos == null)
					return s;
				if (pos.customParams != null)
					for (_v in pos.customParams)
						s += ", " + _v.string();
				return s;
			}

			var p:String = null;
			if (pos != null)
			{
				p = pos.fileName + ":" + pos.lineNumber;
				if (pos.methodName != null && pos.methodName.length > 0)
					p += " - " + (pos.className == null || pos.className.length == 0 ? pos.methodName : pos.className + "." + pos.methodName) + "()";
			}

			final e = __log.pop().set(p, formatOutput(v, pos), Date.now());
			__log.unshift(e);

			final str = e.toString();
			LOG_FULL += '$str\n';

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

		super(gameWidth, gameHeight, Init, fps, fps, true);
		#if (sys && debug)
		trace("\"OMG, THIS GAME MESSES WITH YOUR COMPUTER!!🤯\"\nMesses with your computer in question:\nur username: " + Sys.environment()["USERNAME"]);
		#end
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
		__exit = new TextField();
		__exit.defaultTextFormat = new openfl.text.TextFormat(AssetsPath.font("sans") /* SAAAAANS */, 24, 0xFFFFFF, true);
		__exit.selectable = __exit.mouseEnabled = __exit.mouseWheelEnabled = false;
		__exit.autoSize = LEFT;
		__exit.alpha = 0;
		addChild(__exit);
		__exit.x = 2;
		#end

		#if SHOW_FPS
		addChild(Main.fps = new debug.FPS());
		#end

		#if debug
		__logDisplay = new TextField();
		__logDisplay.defaultTextFormat = new openfl.text.TextFormat("_sans", 10, 0xFFFFFF, true);
		__logDisplay.selectable = __logDisplay.mouseEnabled = __logDisplay.mouseWheelEnabled = false;
		__logDisplay.multiline = __logDisplay.wordWrap = true;
		__logDisplay.autoSize = LEFT;
		__logDisplay.width = 400;
		addChild(__logDisplay);
		__logDisplay.x = 10;
		__logDisplay.y = 45;

		__logDisplay.shader = new shaders.Outline.OutlineShader(1.25);

		FlxG.console.registerFunction("clearGameLog", () ->
		{
			__logDisplay.text = "";
			for (entry in __log)
			{
				entry.source = null;
				entry.text = null;
				entry.time = null;
				entry._timeout = __logTimeout;
			}
		}
		);
		#end

		// stolen shader coord fix :trollface:
		FlxG.signals.gameResized.add((w, h) ->
		{
			if (FlxG.cameras.list.length == 1 && FlxG.camera.filters != null && FlxG.camera.filters.length > 0)
				FlxG.camera.flashSprite.__cleanup();
			else
				for (camera in FlxG.cameras.list)
					if (camera.filters != null && camera.filters.length > 0)
						camera.flashSprite.__cleanup();

			if (this.filters != null && this.filters.length > 0)
				this.__cleanup();

			#if sys
			__exit.scaleX = FlxG.scaleMode.scale.x;
			__exit.scaleY = FlxG.scaleMode.scale.y;
			__exit.y = FlxG.scaleMode.gameSize.y - 28 * __exit.scaleY;
			#end
		});
	}

	override function step()
	{
		super.step();
		#if debug __updateLog(FlxG.elapsed); #end
		#if sys __undertale(FlxG.elapsed); #end
	}

	#if debug
	@:noCompletion /*inline*/ function __updateLog(e:Float)
	{
		var str = "";
		var entry:LogEntry;

		if (__log[0]._timeout <= __logTimeout)
		{
			for (i in 0...__logLen)
			{
				entry = __log[i];
				if (entry == null || entry._timeout > __logTimeout)
					continue;

				entry._timeout += e;
				if (entry._timeout < __logTimeout && entry.text.length > 0)
				{
					str += entry.toString();
					if (i < __logLen-1)
						str += "\n";
				}
			}
		}

		__logDisplay.text = str;
	}
	#end

	#if sys
	@:noCompletion var __exit__timer = 0.;

	/**
		Undertale
	**/
	@:noCompletion /*inline*/ function __undertale(e:Float)
	{
		final a = FlxG.keys.pressed.ESCAPE ? e : -e;
		if (__exit.alpha == 0 && a < 0)
			return;

		__exit.alpha += a;

		final dots = __exit.alpha < .4 ? "." : __exit.alpha < .6 ? ".." : __exit.alpha < .8 ? "..." : "....";
		__exit.text = "EXITING" + dots;

		if (__exit.alpha == 1.)
		{
			__exit__timer += e;
			if (__exit__timer > .3)
				Sys.exit(0);
		}
		else
			__exit__timer = 0.;
	}
	#end
}

@:noCompletion /*private*/ final class LogEntry
{
	public var source:String;
	public var text:String;
	public var time:Date;
	@:allow(Game) var _timeout = Game.__logTimeout;

	@:keep inline public function new(text = "", ?source:String, ?time:Date):Void
	{
		this.set(source, text, time);
	}

	inline public function set(source:String, text:String, time:Date):LogEntry
	{
		this._timeout = 0;
		this.source = source;
		this.text = text;
		this.time = time;
		return this;
	}

	inline public function toString():String
	{
		var str = '<${__formatTime(time)}>';
		if (source != null)
			str += ' [$source]';
		return '$str > $text';
	}

	@:noCompletion inline static function __formatTime(t:Date):String
	{
		if (t == null)
			return "00:00:00";

		final h = t.getHours();
		final m = t.getMinutes();
		final s = t.getSeconds();
		return '${h > 9 ? '$h' : '0$h'}:${m > 9 ? '$m' : '0$m'}:${s > 9 ? '$s' : '0$s'}';
	}
}
