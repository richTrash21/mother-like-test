package;

// import openfl.Lib;
// import openfl.display.StageScaleMode;

class Main extends openfl.display.Sprite
{
	public function new()
	{
		super();
		addChild(new Game(#if flash 640, 480, #end Init, 60, 60, true));
		addChild(new debug.FPS(#if flash 10, 10, #end 0xFFFFFF));
		// Lib.current.stage.align = "tl";
		// Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
	}
}

class Game extends flixel.FlxGame
{
	override function create(_)
	{
		// TODO: custom sound tray
		// _customSoundTray = 
		super.create(_);
	}
}
