package util;

/**
	Util for getting assets paths
**/
// @:build(flixel.system.FlxAssets.buildFileReferences("assets", true))
class Assets
{
	inline static final IMG_EXT = "png";
	inline static final SND_EXT = #if flash "mp3" #else "ogg" #end;

	/**
		Simple internal function to get full file path
	**/
	@:noCompletion inline static function __filePath(key:String, ext:String, ?id:Int, ?library:String):String
	{
		final name = id == null ? key : key + id;
		final path = library == null ? "assets" : 'assets/$library';
		return '$path/$name.$ext';
	}

	/**
		Gets full image file path
	**/
	inline public static function image(key:String, ?id:Int):String
	{
		return __filePath(key, IMG_EXT, id, "images");
	}

	/**
		Gets full sound file path
	**/
	inline public static function sound(key:String, ?id:Int):String
	{
		return __filePath(key, SND_EXT, id, "sounds");
	}

	/**
		Gets full music file path
	**/
	inline public static function music(key:String, ?id:Int):String
	{
		return __filePath(key, SND_EXT, id, "music");
	}

	/**
		Gets music track for overworld
	**/
	inline public static function worldMusic(key:String, ?id:Int):String
	{
		return music('overworld/$key', id);
	}

	/**
		Gets music track for battle
	**/
	inline public static function battleMusic(key:String, ?id:Int):String
	{
		return music('battle/$key', id);
	}

	/**
		Gets random image
	**/
	inline public static function randomImage(key:String, min = 0, ?max:Int, ?exclude:Array<Int>):String
	{
		final id = max == null ? min : FlxG.random.int(min, max, exclude);
		return image(key, id);
	}
}
