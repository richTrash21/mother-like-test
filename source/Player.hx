package;

class Player extends flixel.FlxSprite
{
	final SPEED:Float = 300;

	public function new(X:Float = 0, Y:Float = 0)
	{
		super(X, Y, Assets.image("arrow"));
		// makeGraphic(30, 50, FlxColor.RED);

		// for collision
		// offset.set(10, 20);
		width = 30;
		height = 30;
		centerOffsets();

		final DRAG = SPEED * 12;
		drag.set(DRAG, DRAG);
		angle = -90;

		// setFacingFlip(LEFT, true, false);
		// setFacingFlip(RIGHT | UP, false, false);
		// setFacingFlip(DOWN, false, true);
	}

	/** Input system **/
	function movement()
	{
		final KEY_LEFT	= FlxG.keys.anyPressed([LEFT, A]);
		final KEY_RIGHT	= FlxG.keys.anyPressed([RIGHT, D]);
		final KEY_UP	= FlxG.keys.anyPressed([UP, W]);
		final KEY_DOWN	= FlxG.keys.anyPressed([DOWN, S]);

		final KEY_SPRINT = FlxG.keys.pressed.SHIFT;
		final REAL_SPEED = KEY_SPRINT ? SPEED * 2 : SPEED;

		if (KEY_LEFT || KEY_RIGHT || KEY_UP || KEY_DOWN)
		{
			if ((KEY_LEFT || KEY_RIGHT) && !(KEY_LEFT && KEY_RIGHT))
			{
				velocity.x = KEY_RIGHT ? REAL_SPEED : -REAL_SPEED;
			}
			if ((KEY_UP || KEY_DOWN) && !(KEY_UP && KEY_DOWN))
			{
				velocity.y = KEY_DOWN ? REAL_SPEED : -REAL_SPEED;
			}

			facing = FlxDirectionFlags.fromBools(KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN);
			angle = facing.degrees;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		movement();
	}
}
