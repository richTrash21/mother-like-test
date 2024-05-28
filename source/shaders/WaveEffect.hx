package shaders;

import openfl.display3D.Context3DWrapMode;

/**
	Modified WiggleEffect shader from flixel demos (https://haxeflixel.com/demos/BlendModeShaders/)
	NOTE: Doesn't work on flash (for some reason idk, wont fix anyway)
	NOTE UPD: You know what? Fuck flash, nobody cares about making flash games nowdays anyway.
**/
@:access(openfl.display.Shader.__bitmap) // to avoid casting from/to data variable
class WaveEffect extends ShaderController<WaveShader>
{
	/**
		Whitch texture wrap mode shader should use?
	**/
	public var wrap(get, set):Context3DWrapMode;

	/**
		Should this shader be pixel perfect?
	**/
	public var pixelPerfect(get, set):Bool;

	/**
		Shader effect on the X axis
	**/
	public var x(get, set):WiggleEffectType;

	/**
		Shader effect on the Y axis
	**/
	public var y(get, set):WiggleEffectType;

	// main shader variables
	public var speed(get, set):Float;
	public var frequency(get, set):Float;
	public var amplitude(get, set):Float;

	public function new(parent:FlxSprite):Void
	{
		shader = WaveShader.get();
		wrap = REPEAT; // let texture repeat indefenetly
		super(parent);
	}

	override public function update(elapsed:Float):Void
	{
		if (enabled)
			shader.uTime.value[0] += elapsed;
	}

	public function setEffect(x:WiggleEffectType, ?y:WiggleEffectType):Void
	{
		this.x = x;
		this.y = y ?? x;
	}

	override public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("active", active),
			LabelValuePair.weak("exists", exists),
			LabelValuePair.weak("shader", FlxStringUtil.getDebugString([
				LabelValuePair.weak("name", FlxStringUtil.getClassName(WaveShader, true)),
				LabelValuePair.weak("wrap", cast (wrap : String).toUpperCase()),
				LabelValuePair.weak("pixelPerfect", pixelPerfect),
				LabelValuePair.weak("x", cast (x : String).toUpperCase()),
				LabelValuePair.weak("y", cast (y : String).toUpperCase()),
				LabelValuePair.weak("speed", speed),
				LabelValuePair.weak("frequency", frequency),
				LabelValuePair.weak("amplitude", amplitude)
			]))
		]);
	}

	override public function destroy()
	{
		#if SHADER_POOL
		shader.put();
		#else
		shader.dispose();
		#end
		super.destroy();
	}

	@:noCompletion inline function set_x(value:WiggleEffectType):WiggleEffectType
	{
		return shader.effectX.value[0] = value;
	}

	@:noCompletion inline function get_x():WiggleEffectType
	{
		return shader.effectX.value[0];
	}

	@:noCompletion inline function set_y(value:WiggleEffectType):WiggleEffectType
	{
		return shader.effectY.value[0] = value;
	}

	@:noCompletion inline function get_y():WiggleEffectType
	{
		return shader.effectY.value[0];
	}

	@:noCompletion inline function set_speed(value:Float):Float
	{
		return shader.uSpeed.value[0] = value;
	}

	@:noCompletion inline function get_speed():Float
	{
		return shader.uSpeed.value[0];
	}

	@:noCompletion inline function set_frequency(value:Float):Float
	{
		return shader.uFrequency.value[0] = value;
	}

	@:noCompletion inline function get_frequency():Float
	{
		return shader.uFrequency.value[0];
	}

	@:noCompletion inline function set_amplitude(value:Float):Float
	{
		return shader.uAmplitude.value[0] = value;
	}

	@:noCompletion inline function get_amplitude():Float
	{
		return shader.uAmplitude.value[0];
	}

	@:noCompletion inline function set_wrap(value:Context3DWrapMode):Context3DWrapMode
	{
		return shader.__bitmap.wrap = value;
	}

	@:noCompletion inline function get_wrap():Context3DWrapMode
	{
		return shader.__bitmap.wrap;
	}

	@:noCompletion inline function set_pixelPerfect(value:Bool):Bool
	{
		return shader.pixelPerfect.value[0] = value;
	}

	@:noCompletion inline function get_pixelPerfect():Bool
	{
		return shader.pixelPerfect.value[0];
	}
}

class WaveShader extends Shader
{
	#if SHADER_POOL
	static var pool = new FlxPool<WaveShader>(WaveShader.new.bind(0, 0, 0., 0., 0., true));
	#end

	inline public static function get(effectX = 0, effectY = 0, speed = 0., frequency = 0., amplitude = 0., pixelPerfect = true):WaveShader
	{
		#if SHADER_POOL
		final s = pool.get().set(effectX, effectY, speed, frequency, amplitude, pixelPerfect);
		s._inPool = false;
		return s;
		#else
		return new WaveShader(effectX, effectY, speed, frequency, amplitude, pixelPerfect);
		#end
	}

	@:glFragmentSource('
		#pragma header

		/**
			Time measure for this shader instance
		**/
		uniform float uTime;
		
		// type constants (duhh)
		const int EFFECT_TYPE_NONE = -1;
		const int EFFECT_TYPE_DREAMY = 0;
		const int EFFECT_TYPE_HEAT_WAVE = 1;
		const int EFFECT_TYPE_FLAG = 2;
		const int EFFECT_TYPE_SEPERATE = 3;

		const int SEPERATE_PIXEL_SIZE = 1;

		/**
			Should this sahder be pixel perfect?
		**/
		uniform bool pixelPerfect;
		
		/**
		Effect type for X axis  **/
		uniform int effectX;

		/**
			Effect type for Y axis
		**/
		uniform int effectY;
		
		/**
			How fast the waves move over time
		**/
		uniform float uSpeed;
		
		/**
			Number of waves over time
		**/
		uniform float uFrequency;
		
		/**
			How much the pixels are going to stretch over the waves
		**/
		uniform float uAmplitude;

		/**
			A function that resolves wave motion per axis
		**/
		float resolveSineWave(int waveType, vec2 point, vec2 res)
		{
			float resolvedPoint = 0.;

			if (waveType == EFFECT_TYPE_DREAMY || waveType == EFFECT_TYPE_SEPERATE)
			{
				float offset = sin(point.y * uFrequency + uTime * uSpeed) * uAmplitude;
				// offset *= point.y - 1.; // <- Uncomment to stop bottom part of the screen from moving

				resolvedPoint = waveType == EFFECT_TYPE_SEPERATE && mod(ceil(point.y * res.y / SEPERATE_PIXEL_SIZE), 2.) == 0. ? -offset : offset;
			}
			else if (waveType == EFFECT_TYPE_HEAT_WAVE)
			{
				resolvedPoint = sin(point.x * uFrequency + uTime * uSpeed) * uAmplitude;
			}
			else if (waveType == EFFECT_TYPE_FLAG)
			{
				float flagOffset = 5.;
				resolvedPoint = sin(point.x * uFrequency + flagOffset * point.y + uTime * uSpeed) * uAmplitude;
			}

			return resolvedPoint;
		}

		vec2 sineWave(vec2 coord, vec2 texture)
		{
			// if effect is disabled then just skip it
			if (effectX == EFFECT_TYPE_NONE && effectY == EFFECT_TYPE_NONE)
				return coord;

			if (pixelPerfect)
				coord = floor(coord * texture) / texture;

			// learned a bit how glsl works and damn that shit is 🔥🔥
			vec2 wave = vec2(resolveSineWave(effectX, coord, texture), resolveSineWave(effectY, vec2(coord.y, coord.x), vec2(texture.y, texture.x)));

			return coord + wave;
		}

		void main()
		{
			vec2 uv = sineWave(openfl_TextureCoordv, openfl_TextureSize);
			gl_FragColor = flixel_texture2D(bitmap, uv);
		}')
	public function new(effectX = 0, effectY = 0, speed = 0., frequency = 0., amplitude = 0., pixelPerfect = true)
	{
		super();
		this.uTime.value = [0];

		this.effectX.value = [effectX];
		this.effectY.value = [effectY];

		this.uSpeed.value     = [speed];
		this.uFrequency.value = [frequency];
		this.uAmplitude.value = [amplitude];

		this.pixelPerfect.value = [pixelPerfect];
	}

	#if SHADER_POOL
	override public function put()
	{
		if (!_inPool)
		{
			_inPool = true;
			pool.putUnsafe(this);
		}
	}
	#end

	inline public function set(effectX = 0, effectY = 0, speed = 0., frequency = 0., amplitude = 0., pixelPerfect = true):WaveShader
	{
		this.effectX.value[0] = effectX;
		this.effectY.value[0] = effectY;

		this.uSpeed.value[0]     = speed;
		this.uFrequency.value[0] = frequency;
		this.uAmplitude.value[0] = amplitude;

		this.pixelPerfect.value[0] = pixelPerfect;
		return this;
	}
}

enum abstract WiggleEffectType(Int) from Int from WiggleEffectType to Int
{
	var NONE      = -1;
	var DREAMY    = 0;
	var HEAT_WAVE = 1;
	var FLAG      = 2;
	var SEPERATE  = 3;

	@:from inline static function fromString(v:String):WiggleEffectType
	{
		return switch (v.toLowerCase())
		{
			case "dreamy":     DREAMY;
			case "heat_wave":  HEAT_WAVE;
			case "flag":       FLAG;
			case "seperate":   SEPERATE;
			default:           NONE;
		}
	}

	@:to inline function toString():String
	{
		return switch (cast this : WiggleEffectType)
		{
			case DREAMY:     "dreamy";
			case HEAT_WAVE:  "heat_wave";
			case FLAG:       "flag";
			case SEPERATE:   "seperate";
			default:         "none";
		}
	}
}
