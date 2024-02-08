package util;

import flixel.util.FlxDirectionFlags;
import flixel.util.FlxAxes;
import flixel.FlxCamera;
import flixel.FlxObject;

using util.CameraUtil;

class CameraUtil
{
	/**
		Sets objects position to the given border of the camera
		@param   obj      The object you need to position.
		@param   border   The border to which you need the object to be pasitioned at.
		                  If you want to set objects position to the corner, you need
						  to specidy border flags that corresponds to the desirable corner
						  (e.g. `CameraUtil.setPositionOnCamera(myObject, LEFT | UP);`)
		@param   offset   Pretty self explanatory isn't it?
		@param   camera   A camera to which you want to set objects position.
		                  If `null`, `FlxG.camera` is used.
	**/
	/*inline*/ public static function setPositionOnCamera(obj:FlxObject, border:Direction, offset = 0., ?camera:FlxCamera):FlxObject
	{
		if (camera == null)
			camera = FlxG.camera;

		return switch (border)
		{
			// standart cases
			case LEFT:   obj.__left(offset, camera);
			case RIGHT:  obj.__right(offset, camera);
			case UP:     obj.__top(offset, camera);
			case DOWN:   obj.__bottom(offset, camera);

			// most common combinations
			case UP_LEFT:     obj.__top(offset, camera).__left(offset, camera);
			case UP_RIGHT:    obj.__top(offset, camera).__right(offset, camera);
			case DOWN_LEFT:   obj.__bottom(offset, camera).__left(offset, camera);
			case DOWN_RIGHT:  obj.__bottom(offset, camera).__right(offset, camera);

			// fucked up stuff, idk why i added these
			case LEFT_RIGHT:  obj.__center(X, offset, camera);
			case UP_DOWN:     obj.__center(Y, offset, camera);
			case ANY:         obj.__center(XY, offset, camera);

			// unidentified case - warn and return the object
			default:
				FlxG.log.warn('Can\'t set to "${border.toString()}" flag!');
				obj;
		}
	}

	@:noCompletion inline /*public*/ static function __left(obj:FlxObject, offset:Float, camera:FlxCamera):FlxObject
	{		
		obj.x = camera.viewMarginLeft + offset;
		return obj;
	}

	@:noCompletion inline /*public*/ static function __right(obj:FlxObject, offset:Float, camera:FlxCamera):FlxObject
	{
		obj.x = camera.viewWidth - obj.width - offset;
		return obj;
	}

	@:noCompletion inline /*public*/ static function __top(obj:FlxObject, offset:Float, camera:FlxCamera):FlxObject
	{
		obj.y = camera.viewMarginTop + offset;
		return obj;
	}

	@:noCompletion inline /*public*/ static function __bottom(obj:FlxObject, offset:Float, camera:FlxCamera):FlxObject
	{
		obj.y = camera.viewHeight - obj.height - offset;
		return obj;
	}

	// uhhhhhhhhhhhhhhh... idk???????????
	@:noCompletion inline /*public*/ static function __center(obj:FlxObject, axes:FlxAxes, offset:Float, camera:FlxCamera):FlxObject
	{
		if (axes.x) obj.x = (camera.viewWidth - obj.width) * 0.5 + offset;
		if (axes.y) obj.y = (camera.viewHeight - obj.height) * 0.5 + offset;
		return obj;
	}
}

private enum abstract Direction(Int) from Int from FlxDirectionFlags to Int
{
	var LEFT  = 0x0001; // FlxDirection.LEFT;
	var RIGHT = 0x0010; // FlxDirection.RIGHT;
	var UP    = 0x0100; // FlxDirection.UP;
	var DOWN  = 0x1000; // FlxDirection.DOWN;

	var UP_LEFT    = 0x0101;
	var UP_RIGHT   = 0x0110;
	var DOWN_LEFT  = 0x1001;
	var DOWN_RIGHT = 0x1010;

	var LEFT_RIGHT = 0x0011;
	var UP_DOWN    = 0x1100;

	/** Special-case constant meaning no directions. */
	var NONE = 0x0000;

	/** Special-case constant meaning "up". */
	var CEILING = 0x0100; // UP;

	/** Special-case constant meaning "down" */
	var FLOOR = 0x1000; // DOWN;

	/** Special-case constant meaning "left" and "right". */
	var WALL = 0x0011; // LEFT | RIGHT;

	/** Special-case constant meaning any, or all directions. */
	var ANY = 0x1111; // LEFT | RIGHT | UP | DOWN;

	/**
		Calculates the angle (in degrees) of the facing flags.
		Returns 0 if two opposing flags are true.
		@since 5.0.0
	**/
	public var degrees(get, never):Float;
	function get_degrees():Float
	{
		return switch (this)
		{
			// case RIGHT: 0;
			case DOWN: 90;
			case UP: -90;
			case LEFT: 180;
			case DOWN_RIGHT: 45;
			case DOWN_LEFT: 135;
			case UP_RIGHT: -45;
			case UP_LEFT: -135;
			default: 0;
		}
	}

	/**
		Calculates the angle (in radians) of the facing flags.
		Returns 0 if two opposing flags are true.
		@since 5.0.0
	**/
	public var radians(get, never):Float;
	inline function get_radians():Float return degrees * flixel.math.FlxAngle.TO_RAD;

	/**
		Returns true if this contains **all** of the supplied flags.
	**/
	public inline function has(dir:Direction):Bool return this & dir == dir;

	/**
		Returns true if this contains **any** of the supplied flags.
	**/
	public inline function hasAny(dir:Direction):Bool return this & dir > 0;

	/**
		Creates a new `FlxDirections` that includes the supplied directions.
	**/
	public inline function with(dir:Direction):Direction return this | dir;

	/**
		Creates a new `FlxDirections` that excludes the supplied directions.
	**/
	public inline function without(dir:Direction):Direction return this & ~dir;

	public function toString()
	{
		if (this == NONE)
			return "NONE";

		var str = "";
		if (has(LEFT))  str += " | L";
		if (has(RIGHT)) str += " | R";
		if (has(UP))    str += " | U";
		if (has(DOWN))  str += " | D";

		// remove the first " | "
		return str.substr(3);
	}

	/**
		Generates a FlxDirectonFlags instance from 4 bools
		@since 5.0.0
	**/
	public static function fromBools(l:Bool, r:Bool, u:Bool, d:Bool):Direction
		return (l ? LEFT : NONE) | (r ? RIGHT : NONE) | (u ? UP : NONE) | (d ? DOWN : NONE);

	// Expose int operators
	@:op(A & B) static function and(a:Direction, b:Direction):Direction;
	@:op(A | B) static function or(a:Direction, b:Direction):Direction;
	@:op(A > B) static function gt(a:Direction, b:Direction):Bool;
	@:op(A < B) static function lt(a:Direction, b:Direction):Bool;
	@:op(A >= B) static function gte(a:Direction, b:Direction):Bool;
	@:op(A <= B) static function lte(a:Direction, b:Direction):Bool;
}