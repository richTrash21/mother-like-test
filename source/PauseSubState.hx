package;

import flixel.text.FlxText;
import flixel.tweens.FlxTween;

class PauseSubState extends flixel.FlxSubState
{
	@:noCompletion var text:FlxText;
	@:noCompletion var _zoomIn = true;
	@:noCompletion var _textTween:FlxTween;

	public function new()
	{
		super();

		text = new FlxText(0, 80, 0, "PAUSED", 36);
		// text.scrollFactor.set();
		add(text.screenCenter(X));
		
		final helpText = new FlxText(3, #if flash 0, 0, #end "Press ESC to unpause.", 12);
		// helpText.scrollFactor.set();
		helpText.y = FlxG.height - helpText.height - 1;
		add(helpText);

		_textTween = FlxTween.angle(text, -5, 5, 0.8, {ease: flixel.tweens.FlxEase.quadInOut, type: PINGPONG});

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
		if (FlxG.renderTile)
			_bgSprite.cameras = cameras;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		final factor = elapsed * 0.3;
		if (_zoomIn)
			text.scale.add(factor, factor);
		else
			text.scale.subtract(factor, factor);

		if (text.scale.x > 1.15)
			_zoomIn = false;
		else if (text.scale.x < 0.85)
			_zoomIn = true;

		if (bgColor != 0x88000000)
			bgColor = FlxColor.interpolate(bgColor, 0x88000000, elapsed * 12);

		if (FlxG.keys.justPressed.ESCAPE)
		{
			close();
			FlxG.camera.followLerp = PlayState._cameraLerp;
		}
	}

	override function destroy()
	{
		_textTween.destroy();
		super.destroy();
	}
}
