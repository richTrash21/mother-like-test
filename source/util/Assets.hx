package util;

// @:build(flixel.system.FlxAssets.buildFileReferences("assets", true))
class Assets
{
	inline public static function image(key:String, ext:String = "png"):String
	{
		return 'assets/images/$key.$ext';
	}

	inline public static function sound(key:String, ext:String = "ogg"):String
	{
		return 'assets/sound/$key.$ext';
	}

	inline public static function music(key:String, ext:String = "ogg"):String
	{
		return 'assets/music/$key.$ext';
	}
}
