package util;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxAssets.FlxShader;
import flixel.FlxCamera;
import shaders.*;

class ShaderUtil
{
	public static var shaderList(default, null):Map<String, Class<ShaderController<Dynamic>>> =
	[
		"WaveEffect"    => WaveEffect,
		"Displacement"  => Displacement
	];

	// https://stackoverflow.com/questions/12643009/regular-expression-for-floating-point-numbers
	static final FLOAT_REGEX  = ~/^[+-]?(\d+([.]\d*)?|[.]\d+)$/;
	// https://stackoverflow.com/questions/9043551/regex-that-matches-integers-in-between-whitespace-or-start-end-of-string-only
	static final INT_REGEX    = ~/^\d+$/; 
	// https://stackoverflow.com/questions/23148764/regex-to-match-true-or-false
	static final BOOL_REGEX   = ~/^(tru|fals)e$/i;
	// the only one i figured out myself lmao (i hate regular expressions)
	static final BREAK_REGEX  = ~/[\r\n|\r|\n]+/g;
	// idfk how to make array typeof mathcing (nvmd lol)
	static final ARRAY_REGEX  = ~/^\[.+\]$/;
	// okay this one was pretty simple ig
	static final STRING_REGEX = ~/^".+"$/;

	public static function parseOgmoShaderValues(shader:FlxShader, values:String)
	{
		if (shader == null || values == null || values == "")
			return;

		/*inline*/ function setShaderProperty(Shader:FlxShader, Field:String, Value:Any)
		{
			// cant use openfl.display.ShaderParameter😔
			final prop:Dynamic = Reflect.field(Shader, Field);
			if (prop == null)
			{
				trace('NO FIELD NAMED "$Field"!!');
				return;
			}

			if (Value is Array)
			{
				prop.value = Value;
			}
			else if (prop.value == null)
			{
				prop.value = [Value];
			}
			else // lol
			{
				prop.value[0] = Value;
			}
		}

		var propStr:Array<String>;
		final sepStr = BREAK_REGEX.replace(values, "").split(",");
		// trace(sepStr);

		if (sepStr.length == 1) // skip loop if there is only 1 property
		{
			propStr = sepStr.pop().split("=");
			setShaderProperty(shader, propStr[0].trim(), stringToValue(propStr[1]));
			return;
		}

		while (sepStr.length > 0)
		{
			propStr = sepStr.pop().split("=");
			setShaderProperty(shader, propStr[0].trim(), stringToValue(propStr[1]));
		}
	}

	@:noCompletion inline static function stringToValue(value:String):Any
	{
		final trimValue = value.trim();
		return  if (STRING_REGEX.match(trimValue)) // check if value is explicitly a string
				{
					value.substr(value.indexOf("\"")+1, value.lastIndexOf("\"")-1);
				}
				else // if it's not - check everything else
				{
					if (FLOAT_REGEX.match(trimValue)) // is value a float?
					{
						Std.parseFloat(value);
					}
					else if (INT_REGEX.match(trimValue)) // is value an int?
					{
						Std.parseInt(value);
					}
					else if (BOOL_REGEX.match(trimValue)) // is value a bool?
					{
						trimValue == "true";
					}
					else if (ARRAY_REGEX.match(trimValue)) // is value an array?
					{
						[for (val in value.substr(value.indexOf("[")+1, value.lastIndexOf("]")-1).split(",")) stringToValue(val.trim())];
					}
					else // nvmd its just a string
					{
						value;
					}
				}
	}
}

class ShaderController<ShaderClass:FlxShader> extends flixel.FlxBasic
{
	/**  An actual shader reference that can be used on sprites  **/
	public var shader(default, null):ShaderClass;

	// so it wont call draw()
	public function new() { super(); visible = alive = false; }

	#if FLX_DEBUG
	// clear unnecessary code from FlxBasic
	override public function update(elapsed:Float) {}
	override public function draw() {}
	#end

	override public function destroy()
	{
		super.destroy();
		shader = null;
	}

	// yeah fuck me
	@:noCompletion override function get_camera():FlxCamera           throw "Don't reference \"camera\" in ShaderController!";
	@:noCompletion override function set_camera(_):FlxCamera          throw "Don't reference \"camera\" in ShaderController!";
	@:noCompletion override function get_cameras():Array<FlxCamera>   throw "Don't reference \"cameras\" in ShaderController!";
	@:noCompletion override function set_cameras(_):Array<FlxCamera>  throw "Don't reference \"cameras\" in ShaderController!";
}

typedef ShaderGroup = FlxTypedGroup<ShaderController<FlxShader>>;
