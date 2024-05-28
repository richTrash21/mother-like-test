package;

import flixel.tweens.FlxTween;
import flixel.text.FlxText;

class PauseSubState extends flixel.FlxSubState
{
	@:noCompletion var text:FlxText;
	@:noCompletion var textTween:FlxTween;

	public function new()
	{
		super();
		_bgColor = 0;

		text = new FlxText(0, 80, 0, "PAUSED", 36);
		// text.font = Assets.font("sans");
		add(text.screenCenter(X));
		
		final helpText = new FlxText(3, "Press ENTER to unpause.", 12);
		// helpText.font = Assets.font("sans");
		helpText.y = FlxG.height - helpText.height - 1;
		add(helpText);

		textTween = FlxTween.angle(text, -5, 5, .8, {ease: flixel.tweens.FlxEase.quadInOut, type: PINGPONG});

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
		if (FlxG.renderTile)
			_bgSprite.cameras = cameras;
	}

	@:noCompletion var __zoomIn = true;
	// @:noCompletion var __doFade = true;
	@:noCompletion var __fadeColor:FlxColor = 0x88000000;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		final factor = elapsed * .3;
		if (__zoomIn)
			text.scale.add(factor, factor);
		else
			text.scale.subtract(factor, factor);

		if (text.scale.x > 1.15)
			__zoomIn = false;
		else if (text.scale.x < .85)
			__zoomIn = true;

		if (bgColor.alpha < __fadeColor.alpha)
		{
			bgColor.alphaFloat = FlxMath.lerp(bgColor.alphaFloat, __fadeColor.alphaFloat, elapsed * 10.4);
			if (FlxG.renderTile)
				bgColor = bgColor; // trigger set_bgColor()
			// trace("interpolating color: 0x" + bgColor.hex(8) + " (" + bgColor + ")");
			// trace(bgColor.getColorInfo());
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			close();
			FlxG.camera.followLerp = PlayState.__cameraLerp;
		}
	}

	override function destroy()
	{
		textTween.destroy();
		super.destroy();
	}
}
