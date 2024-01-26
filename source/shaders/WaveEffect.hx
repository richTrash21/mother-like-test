package shaders;

import openfl.display3D.Context3DWrapMode;

enum abstract WiggleEffectType(Int) from Int from WiggleEffectType to Int
{
	var NONE = -1;
	var DREAMY = 0;
	var HEAT_WAVE = 1;
	var FLAG = 2;
	var SEPERATE = 3;
}

/**
	Modified WiggleEffect shader from flixel demos (https://haxeflixel.com/demos/BlendModeShaders/)
	NOTE: Doesn't work on flash (for some reason idk, wont fix anyway)
**/
class WaveEffect
{
	/**  An actual shader reference that can be used on sprites  **/
	public var shader(default, null):WaveShader;
	/**  Whitch texture wrap mode shader should use?  **/
	public var wrap(get, set):Context3DWrapMode;
	/**  Should this shader be pixelperfect?  **/
	public var pixelPerfect(get, set):Bool;

	/**  Shader effect on the X axis  **/
	public var x(get, set):WiggleEffectType;
	/**  Shader effect on the Y axis  **/
	public var y(get, set):WiggleEffectType;

	public var speed(get, set):Float;
	public var frequency(get, set):Float;
	public var amplitude(get, set):Float;

	public function new():Void
	{
		#if !flash
		shader = new WaveShader();
		shader.uTime.value = [0.0];

		shader.effectX.value = [DREAMY];
		shader.effectY.value = [DREAMY];

		shader.uSpeed.value = [0.0];
		shader.uFrequency.value = [0.0];
		shader.uAmplitude.value = [0.0];

		shader.pixelPerfect.value = [true];

		// let texture repeat indefenetly
		wrap = REPEAT;
		#end
	}

	public function update(elapsed:Float):Void
	{
		#if !flash 
		shader.uTime.value[0] += elapsed;
		#end
	}

	public function setEffect(X:WiggleEffectType, ?Y:WiggleEffectType):Void
	{
		this.x = X;
		this.y = Y ?? X;
	}

	@:noCompletion inline function set_x(Value:WiggleEffectType):WiggleEffectType
	{
		return #if !flash shader.effectX.value[0] = #end Value;
	}
	@:noCompletion inline function get_x():WiggleEffectType
	{
		return #if !flash shader.effectX.value[0] #else 0 #end ;
	}

	@:noCompletion inline function set_y(Value:WiggleEffectType):WiggleEffectType
	{
		return #if !flash shader.effectY.value[0] = #end Value;
	}

	@:noCompletion inline function get_y():WiggleEffectType
	{
		return #if !flash shader.effectY.value[0] #else 0 #end ;
	}

	@:noCompletion inline function set_speed(Value:Float):Float
	{
		return #if !flash shader.uSpeed.value[0] = #end Value;
	}

	@:noCompletion inline function get_speed():Float
	{
		return #if !flash shader.uSpeed.value[0] #else 0.0 #end ;
	}

	@:noCompletion inline function set_frequency(Value:Float):Float
	{
		return #if !flash shader.uFrequency.value[0] = #end Value;
	}

	@:noCompletion inline function get_frequency():Float
	{
		return #if !flash shader.uFrequency.value[0] #else 0.0 #end ;
	}

	@:noCompletion inline function set_amplitude(Value:Float):Float
	{
		return #if !flash shader.uAmplitude.value[0] = #end Value;
	}

	@:noCompletion inline function get_amplitude():Float
	{
		return #if !flash shader.uAmplitude.value[0] #else 0.0 #end ;
	}

	@:noCompletion inline function set_wrap(Value:Context3DWrapMode):Context3DWrapMode
	{
		return #if !flash shader.data.bitmap.wrap = #end Value;
	}

	@:noCompletion inline function get_wrap():Context3DWrapMode
	{
		return #if !flash shader.data.bitmap.wrap #else 0 #end ;
	}

	@:noCompletion inline function set_pixelPerfect(Value:Bool):Bool
	{
		return #if !flash shader.pixelPerfect.value[0] = #end Value;
	}

	@:noCompletion inline function get_pixelPerfect():Bool
	{
		return #if !flash shader.pixelPerfect.value[0] #else false #end ;
	}
}

class WaveShader extends flixel.system.FlxAssets.FlxShader
{
	@:glFragmentSource('
		#pragma header
		/**  Time measure for this shader instance  **/
		uniform float uTime;
		
		// type constants (duhh)
		const int EFFECT_TYPE_NONE = -1;
		const int EFFECT_TYPE_DREAMY = 0;
		const int EFFECT_TYPE_HEAT_WAVE = 1;
		const int EFFECT_TYPE_FLAG = 2;
		const int EFFECT_TYPE_SEPERATE = 3;

		const int SEPERATE_PIXEL_SIZE = 1;

		/**  Should this sahder be pixel perfect?  **/
		uniform bool pixelPerfect;
		
		/**  Effect type for X axis  **/
		uniform int effectX;

		/**  Effect type for Y axis  **/
		uniform int effectY;
		
		/**  How fast the waves move over time  **/
		uniform float uSpeed;
		
		/**  Number of waves over time  **/
		uniform float uFrequency;
		
		/**  How much the pixels are going to stretch over the waves  **/
		uniform float uAmplitude;

		/**  A function that resolves wave motion per axis  **/
		float resolveSineWave(int waveType, vec2 point1, vec2 point2)
		{
			float resolvedPoint = 0.0;

			if (waveType == EFFECT_TYPE_DREAMY || waveType == EFFECT_TYPE_SEPERATE)
			{
				float offset = sin(point1.y * uFrequency + uTime * uSpeed) * uAmplitude;
				// offset *= point1.y - 1.0; // <- Uncomment to stop bottom part of the screen from moving

				resolvedPoint = waveType == EFFECT_TYPE_SEPERATE && mod(ceil(point1.y * point2.y / SEPERATE_PIXEL_SIZE), 2.0) == 0.0 ? -offset : offset;
			}
			else if (waveType == EFFECT_TYPE_HEAT_WAVE)
			{
				resolvedPoint = sin(point1.x * uFrequency + uTime * uSpeed) * uAmplitude;
			}
			else if (waveType == EFFECT_TYPE_FLAG)
			{
				resolvedPoint = sin(point1.x * uFrequency + 5.0 * point1.y + uTime * uSpeed) * uAmplitude;
			}

			return resolvedPoint;
		}

		vec2 sineWave(vec2 coord, vec2 texture)
		{
			// if effect is disabled then just skip it
			if (effectX == EFFECT_TYPE_NONE && effectY == EFFECT_TYPE_NONE)
			{
				return coord;
			}

			float tex_x = coord.x;
			float tex_y = coord.y;

			if (pixelPerfect)
			{
				tex_x = float(floor(tex_x * texture.x)) / texture.x;
				tex_y = float(floor(tex_y * texture.x)) / texture.x;
			}

			float x = resolveSineWave(effectX, vec2(tex_x, tex_y), vec2(texture.x, texture.y));
			float y = resolveSineWave(effectY, vec2(tex_y, tex_x), vec2(texture.y, texture.x));

			return vec2(tex_x + x, tex_y + y);
		}

		void main()
		{
			vec2 uv = sineWave(openfl_TextureCoordv, openfl_TextureSize);
			gl_FragColor = flixel_texture2D(bitmap, uv);
		}')
	public function new() { super(); }
}
