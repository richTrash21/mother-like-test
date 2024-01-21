package util;

/**
	Util for getting assets paths
**/
// @:build(flixel.system.FlxAssets.buildFileReferences("assets", true))
class Assets
{
	inline static final IMG_EXT = "png";
	inline static final SND_EXT = "ogg";

	/**  Gets full image file path  **/
	inline public static function image(key:String):String
	{
		return 'assets/images/$key.$IMG_EXT';
	}

	/**  Gets full sound file path  **/
	inline public static function sound(key:String):String
	{
		return 'assets/sound/$key.$SND_EXT';
	}

	/**  Gets full music file path  **/
	inline public static function music(key:String):String
	{
		return 'assets/music/$key.$SND_EXT';
	}

	/**  Gets music track for overworld  **/
	inline public static function worldMusic(key:String):String
	{
		return music('overworld/$key');
	}

	/**  Gets music track for battle  **/
	inline public static function battleMusic(key:String):String
	{
		return music('battle/$key');
	}

	/**  Gets music track with a specific `id`. If `key` is `null`, only `id` will be used  **/
	inline public static function musicID(?key:String, id = 0):String
	{
		final name = key == null ? Std.string(id) : key + id;
		return music(name);
	}

	/**  Gets overworld music track with a specific `id`. If `key` is `null`, only `id` will be used  **/
	inline public static function worldMusicID(?key:String, id = 0):String
	{
		final name = key == null ? Std.string(id) : key + id;
		return worldMusic(name);
	}

	/**  Gets battle music track with a specific `id`. If `key` is `null`, only `id` will be used  **/
	inline public static function battleMusicID(?key:String, id = 0):String
	{
		final name = key == null ? Std.string(id) : key + id;
		return battleMusic(name);
	}
}
