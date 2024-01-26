package;

class Main // extends openfl.display.Sprite
{
	@:allow(Game)
	public static var fps(default, null):debug.FPS;

	// idk but its kinda cool to lock game creation to the only class that can make it :trollface:
	@:allow(ApplicationMain)
	static function main()
	{
		openfl.Lib.application.window.stage.addChild(new Game(#if flash 640, 480, #end Init, 60, 60, true));
	}

	/*public function new()
	{
		super();
		addChild(new Game(#if flash 640, 480, #end Init, 60, 60, true));
		FlxG.game.addChild(fps = new debug.FPS());
	}*/
}

class Game extends flixel.FlxGame
{
	override function create(_)
	{
		// TODO: custom sound tray
		// _customSoundTray = 
		super.create(_);
		addChild(Main.fps = new debug.FPS());
	}
}
