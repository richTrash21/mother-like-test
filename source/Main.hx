package;

// import openfl.Lib;
// import openfl.display.StageScaleMode;

class Main extends openfl.display.Sprite
{
	public function new()
	{
		super();
		addChild(new flixel.FlxGame(0, 0, PlayState, 60, 60, true));
		addChild(new debug.FPS(10, 10, 0xFFFFFF));
		// Lib.current.stage.align = "tl";
		// Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		FlxG.autoPause = false;
	}
}
