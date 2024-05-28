package;

class Player extends flixel.FlxSprite
{
	/**
		Allows to controll whenever player can take input or not.
		Used for cutscenes and stuff.
	**/
	public var readInput(default, set):Bool = true;

	/**
		Whenever player is moving or not.
	**/
	public var moving:Bool;

	/**
		Whenever player has just moved.
	**/
	public var justMoved:Bool;

	/**
		Whenever player has just stopped.
	**/
	public var justStopped:Bool;

	static final SPEED = 300.;

	public function new(x = 0., y = 0.)
	{
		super(x, y);
		loadRotatedGraphic(AssetsPath.image("arrow"), 8);
		// makeGraphic(30, 50, FlxColor.RED);

		// for collision
		offset.set(20, 10);
		setSize(30, 30);

		final DRAG = SPEED * 12;
		drag.set(DRAG, DRAG);
		angle = -90;
	}

	/**
		Input system
	**/
	@:noCompletion /*inline*/ function movement():Bool
	{
		// get main movement inputs
		final KEY_LEFT  = FlxG.keys.anyPressed([LEFT, A]);
		final KEY_RIGHT = FlxG.keys.anyPressed([RIGHT, D]);
		final KEY_UP    = FlxG.keys.anyPressed([UP, W]);
		final KEY_DOWN  = FlxG.keys.anyPressed([DOWN, S]);

		// check if both way keys (or all at once) was pressed
		final LEFT_AND_RIGHT = KEY_LEFT && KEY_RIGHT;
		final UP_AND_DOWN    = KEY_UP && KEY_DOWN;
		final ALL_KEYS       = LEFT_AND_RIGHT && UP_AND_DOWN;

		// sprint check
		final KEY_SPRINT = FlxG.keys.pressed.SHIFT;
		final REAL_SPEED = KEY_SPRINT ? SPEED * 2 : SPEED;

		// move player only when they really moved
		final MOVED = KEY_LEFT || KEY_RIGHT || KEY_UP || KEY_DOWN;
		if (MOVED && !ALL_KEYS)
		{
			if ((KEY_LEFT || KEY_RIGHT) && !LEFT_AND_RIGHT)
				velocity.x = KEY_RIGHT ? REAL_SPEED : -REAL_SPEED;

			if ((KEY_UP || KEY_DOWN) && !UP_AND_DOWN)
				velocity.y = KEY_DOWN ? REAL_SPEED : -REAL_SPEED;

			// shitty fix for facing flag (yeah)
			final prevFacing = facing;

			facing = FlxDirectionFlags.fromBools(
				LEFT_AND_RIGHT ? prevFacing.has(LEFT)  : KEY_LEFT,
				LEFT_AND_RIGHT ? prevFacing.has(RIGHT) : KEY_RIGHT,
				UP_AND_DOWN    ? prevFacing.has(UP)    : KEY_UP,
				UP_AND_DOWN    ? prevFacing.has(DOWN)  : KEY_DOWN
			);
			angle = facing.degrees;
		}
		return MOVED;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// calls movement function and gets whenever player has moved or not
		if (readInput)
		{
			final _prevMoving = moving;
			moving = movement();
			justMoved = !_prevMoving && moving;
			justStopped = _prevMoving && !moving;
			// trace("Moving: " + moving + " | Just Moved: " + justMoved + " | Just Stopped: " + justStopped);
		}
	}

	@:noCompletion inline function set_readInput(value:Bool):Bool
	{
		if (!value) // if input was disabled - flip all movement related flags to false
			moving = justMoved = justStopped = false;
		return readInput = value;
	}
}
