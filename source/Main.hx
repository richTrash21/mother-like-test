package;

import openfl.text.TextField;

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
		openfl.Lib.application.window.stage.addChild(new Game(#if flash 640, 480, #end Init, 60, 60, true));
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
	@:noCompletion var _exit:TextField;

	override function create(e)
	{
		// TODO: custom sound tray
		// _customSoundTray = 
		super.create(e);

		// undertale
		_exit = new TextField();
		_exit.defaultTextFormat = new openfl.text.TextFormat(Assets.font("sans") /* SAAAAANS */, 24, 0xFFFFFF, true);
		_exit.selectable = _exit.mouseEnabled = _exit.mouseWheelEnabled = false;
		_exit.autoSize = LEFT;
		_exit.alpha = 0.;
		addChild(_exit);
		_exit.x = 2.;

		#if SHOW_FPS
		addChild(Main.fps = new debug.FPS());
		#end

		// stolen shader coord fix :trollface:
		FlxG.signals.gameResized.add((_, _) ->
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

			_exit.scaleX = FlxG.scaleMode.scale.x;
			_exit.scaleY = FlxG.scaleMode.scale.y;
			_exit.y = FlxG.scaleMode.gameSize.y - 28. * _exit.scaleY;
		});
	}

	override function step()
	{
		super.step();
		undertale();
	}

	@:noCompletion var _timer = 0.;

	/**  Undertale  **/
	@:noCompletion inline function undertale()
	{
		final a = FlxG.keys.pressed.ESCAPE ? FlxG.elapsed : -FlxG.elapsed;
		_exit.alpha += a;

		final dots = _exit.alpha < .4 ? "." : _exit.alpha < .6 ? ".." : _exit.alpha < .8 ? "..." : "....";
		_exit.text = "EXITING" + dots;

		if (_exit.alpha == 1.)
		{
			_timer += FlxG.elapsed;
			if (_timer > .3) Sys.exit(0);
		}
		else
			_timer = 0.;
	}
}
