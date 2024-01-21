package util;

import flixel.FlxCamera;
import flixel.FlxObject;

class CameraUtil
{
	inline public static function leftBorder(obj:FlxObject, ?camera:FlxCamera):FlxObject
	{
		if (camera == null)
			camera = FlxG.camera;
		
		obj.x = camera.scroll.x - camera.viewMarginX;
		return obj;
	}

	inline public static function rightBorder(obj:FlxObject, ?camera:FlxCamera):FlxObject
	{
		if (camera == null)
			camera = FlxG.camera;
		
		obj.x = (camera.scroll.x + camera.width + camera.viewMarginX) - obj.width;
		return obj;
	}

	inline public static function topBorder(obj:FlxObject, ?camera:FlxCamera):FlxObject
	{
		if (camera == null)
			camera = FlxG.camera;
		
		obj.y = camera.scroll.y - camera.viewMarginY;
		return obj;
	}

	inline public static function bottomBorder(obj:FlxObject, ?camera:FlxCamera):FlxObject
	{
		if (camera == null)
			camera = FlxG.camera;
		
		obj.y = (camera.scroll.y + camera.height + camera.viewMarginY) - obj.height;
		return obj;
	}

	/**
		Sets objects position to the given border of the camera
		@param   obj      The object you need to position.
		@param   border   The border to which you need the object to be pasitioned at.
		                  If you want to set objects position to the corner, you need
						  to specidy border flags that corresponds to the desirable corner
						  (e.g. `CameraUtil.setPositionToCamera(myObject, LEFT | UP);`)
		@param   camera   A camera to which you want to set objects position.
		                  If `null`, `FlxG.camera` is used.
	**/
	inline public static function setPositionToCamera(obj:FlxObject, border:flixel.util.FlxDirectionFlags, ?camera:FlxCamera):FlxObject
	{
		if (border == NONE)
		{
			FlxG.log.warn("Can't set to \"NONE\" flag!");
			return obj;
		}

		switch (border)
		{
			case LEFT:   leftBorder(obj, camera);
			case RIGHT:  rightBorder(obj, camera);
			case UP:     topBorder(obj, camera);
			case DOWN:   bottomBorder(obj, camera);

			case f if (f == UP | LEFT):
				leftBorder(obj, camera);
				topBorder(obj, camera);

			case f if (f == UP | RIGHT):
				rightBorder(obj, camera);
				topBorder(obj, camera);

			case f if (f == DOWN | LEFT):
				leftBorder(obj, camera);
				bottomBorder(obj, camera);

			case f if (f == DOWN | RIGHT):
				rightBorder(obj, camera);
				bottomBorder(obj, camera);
		}
		return obj;
	}
}