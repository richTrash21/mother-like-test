package;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.math.FlxPoint;

class Init extends flixel.FlxState
{
	override function create()
	{
		FlxG.autoPause = false;
		// FlxG.scaleMode = new flixel.system.scaleModes.FillScaleMode();
		#if debug
		FlxG.console.registerClass(Assets);
		FlxG.console.registerClass(openfl.display.Application);
		#end

		FlxTransitionableState.defaultTransIn = new TransitionData(TILES, FlxColor.BLACK, 0.4, FlxPoint.get(-1, -1));
		FlxTransitionableState.defaultTransOut = new TransitionData(TILES, FlxColor.BLACK, 0.4, FlxPoint.get(-1, -1));

		FlxG.switchState(new PlayState());
		// trace(haxe.macro.Context.getDefines());
	}
}