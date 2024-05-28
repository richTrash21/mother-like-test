package util;

enum abstract DataType(String) from String from DataType to String
{
	var PNG = "png";
	var OGG = "ogg";
	var MP3 = "mp3";
	var TTF = "ttf";
	var OTF = "otf";
	var OGMO = "ogmo";
	var JSON = "json";

	var FONT = "ttf";
	var IMAGE = "png";
	var SOUND = #if flash "mp3" #else "ogg" #end;
}

/**
	Util for getting assets paths
**/
// @:build(flixel.system.FlxAssets.buildFileReferences("assets", true))
class AssetsPath
{
	/**
		Say hi to test! :D
	**/
	static var test = "I am Test!";

	/**
		Simple internal function to get full file path
	**/
	@:noCompletion private inline static function __filePath(key:String, ext:DataType, ?id:Int, ?library:String):String
	{
		return '${library == null ? "assets" : 'assets/$library'}/${id == null ? key : key + id}.$ext';
	}

	/**
		Gets full image file path
	**/
	inline public static function image(key:String, ?id:Int):String
	{
		return __filePath(key, IMAGE, id, "images");
	}

	/**
		Gets full sound file path
	**/
	inline public static function sound(key:String, ?id:Int):String
	{
		return __filePath(key, SOUND, id, "sounds");
	}

	/**
		Gets full music file path
	**/
	inline public static function music(key:String, ?id:Int):String
	{
		return __filePath(key, SOUND, id, "music");
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

	/**
		File from data folder
	**/
	inline public static function data(key:String, ext:DataType):String
	{
		return __filePath(key, ext, "data");
	}

	/**
		Full font path.
	**/
	inline public static function font(key:String):String
	{
		return __filePath(key, FONT, "fonts");
	}
}
