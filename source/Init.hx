package;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.math.FlxPoint;

class Init extends flixel.FlxState
{
	override function create()
	{
		#if debug
		FlxG.console.registerClass(Assets);
		FlxG.console.registerClass(openfl.display.Application);
		#end

		// forcing pixel perfect render eheheheh
		#if !flash
		FlxG.cameras.cameraAdded.add((camera:flixel.FlxCamera) -> camera.pixelPerfectRender = true);
		#end
		// FlxG.scaleMode = new flixel.system.scaleModes.FillScaleMode();
		FlxG.autoPause = false;

		FlxTransitionableState.defaultTransIn = new TransitionData(TILES, FlxColor.BLACK, .3, FlxPoint.get(-1, -1));
		FlxTransitionableState.defaultTransOut = new TransitionData(TILES, FlxColor.BLACK, .3, FlxPoint.get(-1, -1));

		FlxG.switchState(new PlayState());
		// trace(haxe.macro.Context.getDefines());
	}
}