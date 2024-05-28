package;

import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.math.FlxPoint;

import util.ShaderUtil.ShaderController;

class Init extends flixel.FlxState
{
	@:allow(Main)
	static var __init: #if (flixel >= "5.6.0") flixel.util.typeLimit.NextState #else Class<flixel.FlxState> #end;
	static var __needToInit = true;

	override function create()
	{
		if (__needToInit)
		{
			#if debug
			FlxG.console.registerClass(AssetsPath);
			FlxG.console.registerClass(util.ShaderUtil);
			FlxG.console.registerClass(openfl.display.Application);
			#end

			// forcing pixel perfect render eheheheh
			FlxG.cameras.cameraAdded.add((camera) -> camera.pixelPerfectRender = true);
			FlxG.autoPause = false;

			// FlxTransitionableState.defaultTransIn  = new TransitionData(TILES, FlxColor.BLACK, .3, FlxPoint.get(-1, -1));
			// FlxTransitionableState.defaultTransOut = new TransitionData(TILES, FlxColor.BLACK, .3, FlxPoint.get(-1, -1));
			FlxTransitionableState.defaultTransIn  = new TransitionData(FADE, FlxColor.BLACK, .85, FlxPoint.get(0, -1));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, .7, FlxPoint.get(0, 1));

			__needToInit = false;
		}

		FlxG.switchState(#if (flixel >= "5.6.0") __init #else Type.createInstance(__init, []) #end);
		// trace(haxe.macro.Context.getDefines());
	}
}