package util;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxStringUtil;
import flixel.util.FlxPool;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxBasic;

class ShaderUtil
{
	// https://stackoverflow.com/questions/12643009/regular-expression-for-floating-point-numbers
	// FLOAT_REGEX
	static final NUMBER_REGEX  = ~/^[+-]?(\d+([.]\d*)?|[.]\d+)$/;
	// https://stackoverflow.com/questions/9043551/regex-that-matches-integers-in-between-whitespace-or-start-end-of-string-only
	// static final INT_REGEX    = ~/^\d+$/;
	static final HEX_REGEX = ~/^0x[A-F0-9]+$/i;
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
		if (shader == null || values == null || values.length == 0)
			return;

		inline function setShaderProperty(shader:FlxShader, field:String, value:Any)
		{
			if (!Reflect.hasField(shader, field))
			{
				trace('NO FIELD NAMED "$field"!!');
				return;
			}

			// cant use openfl.display.ShaderParameter😔
			final prop:Dynamic = Reflect.field(shader, field);
			if (prop.value == null)
				prop.value = [value];
			else if (value is Array)
				prop.value = value;
			else // lol
				prop.value[0] = value;
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
		return  /*if (STRING_REGEX.match(trimValue)) // check if value is explicitly a string
				{
					value.substr(value.indexOf("\"")+1, value.lastIndexOf("\"")-1);
				}
				else*/ if (NUMBER_REGEX.match(trimValue)) // is value a number? (both int and float since it doesn't really matter that much)
				{
					value.parseFloat();
				}
				else if (HEX_REGEX.match(trimValue)) // is a hex int?
				{
					value.parseInt();
				}
				else if (BOOL_REGEX.match(trimValue)) // is value a bool?
				{
					trimValue == "true";
				}
				else if (ARRAY_REGEX.match(trimValue)) // is value an array? (or a vector idk)
				{
					[for (v in value.substr(value.indexOf("[")+1, value.lastIndexOf("]")-1).split(",")) stringToValue(v)];
				}
				else // nvmd unsupported type so just crash the game here :trollface:
				{
					throw 'Unsupported shader value type! ($value)';
				}
	}

	// list of all shaders controlled by ShaderController
	static var __shaderClassCache = new Map<String, Class<ShaderController<Dynamic>>>();

	inline public static function getShader(name:String, ?parent:FlxSprite):ShaderController<Dynamic>
	{
		return Type.createInstance(getShaderClass(name), [parent]);
	}

	inline public static function getShaderClass(name:String):Class<ShaderController<Dynamic>>
	{
		if (__shaderClassCache.exists(name))
			return __shaderClassCache.get(name);

		final c:Class<ShaderController<Dynamic>> = cast Type.resolveClass('shaders.$name');
		if (c != null)
			__shaderClassCache.set(name, c);
		return c;
	}
}

class ShaderController<ShaderClass:Shader> extends FlxBasic
{
	/**
		An actual shader reference that can be used on sprites
	**/
	public var shader(default, null):ShaderClass;

	/**
		Sprite to which shader will be applied
	**/
	public var parent(default, null):FlxSprite;

	/**
		Controlls if this shader enabled or not.
		NOTE: setting this flag to `false` will remove shader from parent sprite and vise versa.
	**/
	public var enabled(default, set):Bool = true;

	/**
		NOTE: Create shader object BEFORE super() call!
		@param parent   Parent sprite object for shader to be set to.
	**/
	public function new(?parent:FlxSprite)
	{
		if (parent != null)
		{
			this.parent = parent;
			this.parent.shader = shader;
		}
		visible = alive = false; // so it wont call draw()
		super();
	}

	#if FLX_DEBUG
	// clear unnecessary code from FlxBasic
	override public function update(elapsed:Float) {}
	override public function draw() {}
	#end

	/**
		!!! WARNING !!!
		DOESN'T DESTROY SHADER ITSELF! JUST FOR MEMORY CLEANUP
	**/
	override public function destroy()
	{
		super.destroy();
		shader = null;
		if (parent != null)
		{
			parent.shader = null;
			parent = null;
		}
	}

	/**
		Template
	**/
	override public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("active", active),
			LabelValuePair.weak("exists", exists),
			LabelValuePair.weak("shader", FlxStringUtil.getDebugString([
				LabelValuePair.weak("name", FlxStringUtil.getClassName(shader, true))
			]))
		]);
	}

	@:noCompletion function set_enabled(value:Bool):Bool
	{
		if (parent != null)
			parent.shader = value ? shader : null;
		return enabled = value;
	}

	// yeah fuck me
	@:noCompletion override function get_camera():FlxCamera           throw "Don't reference \"camera\" in ShaderController object!";
	@:noCompletion override function set_camera(_):FlxCamera          throw "Don't reference \"camera\" in ShaderController object!";
	@:noCompletion override function get_cameras():Array<FlxCamera>   throw "Don't reference \"cameras\" in ShaderController object!";
	@:noCompletion override function set_cameras(_):Array<FlxCamera>  throw "Don't reference \"cameras\" in ShaderController object!";
}

typedef ShaderGroup = FlxTypedGroup<ShaderController<Dynamic>>;

class Shader extends FlxShader implements IFlxPooled
{
	#if SHADER_POOL
	var _inPool:Bool = false;
	#end

	/** Memory cleanup (need testing) **/
	public function dispose()
	{
		if (program != null)
		{
			program.dispose();
			program = null;
		}
		glProgram = null;
		byteCode = null;

		__glFragmentSource = null;
		__glVertexSource = null;
		__data = null;
	}

	public function destroy() {} // for IFlxDestroyable
	public function put() {} // to be implemented in actual shader classes
}
