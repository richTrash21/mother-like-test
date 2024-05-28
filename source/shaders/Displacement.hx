package shaders;

/**
	Hur hur hur hur hur fedy poopybear
**/
class Displacement extends ShaderController<DisplacementShader>
{
	public var factor(get, set):Float;

	public function new(parent:FlxSprite)
	{
		shader = DisplacementShader.get();
		exists = active = false;
		super(parent);
	}

	override public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("active", active),
			LabelValuePair.weak("exists", exists),
			LabelValuePair.weak("shader", FlxStringUtil.getDebugString([
				LabelValuePair.weak("name", FlxStringUtil.getClassName(DisplacementShader, true)),
				LabelValuePair.weak("factor", factor)
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

	@:noCompletion inline function set_factor(value:Float):Float
	{
		return shader.factor.value[0] = value;
	}

	@:noCompletion inline function get_factor():Float
	{
		return shader.factor.value[0];
	}
}

/**
	Port of https://www.youtube.com/watch?v=-Ah8vvXwv5Y with minor abjustments
**/
class DisplacementShader extends Shader
{
	#if SHADER_POOL
	static var pool = new FlxPool<DisplacementShader>(DisplacementShader.new.bind(.4 /*, true*/ ));
	#end

	inline public static function get(factor = .4 /*, pixelPerfect = true*/ ):DisplacementShader
	{
		#if SHADER_POOL
		final s = pool.get().set(factor /*, pixelPerfect*/ );
		s._inPool = false;
		return s;
		#else
		return new DisplacementShader(factor /*, pixelPerfect*/ );
		#end
	}

	@:glFragmentSource('
	#pragma header

	/**
		How much you want this image to be displaced?
	**/
	uniform float factor;

	/**
		Should this sahder be pixel perfect?
	**/
	// uniform bool pixelPerfect;

	/**
		Function that calculates FNAF like sprite displacement
	**/
	vec2 displace(vec2 coord /*, vec2 texture*/ )
	{
		if (factor == 0.)
			return coord;

		float distanceX = distance(coord.x, .5);
		float distanceY = distance(coord.y, .5);

		float offset = (distanceX * (factor * .5)) * distanceY;
		float dir = coord.y > .5 ? -1. : 1.;

		coord.y += distanceX * (offset * 8. * dir);
		
		/*if (pixelPerfect)
			coord = floor(coord * texture) / texture;*/

		return coord;
	}
	
	void main()
	{
		vec2 uv = displace(openfl_TextureCoordv /*, openfl_TextureSize*/ );
		gl_FragColor = flixel_texture2D(bitmap, uv);
	}')
	public function new(factor = .4 /*, pixelPerfect = true*/ )
	{
		super();
		this.factor.value = [factor];
		// this.pixelPerfect.value = [pixelPerfect];
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

	inline public function set(factor = .4 /*, pixelPerfect = true*/ ):DisplacementShader
	{
		this.factor.value[0] = factor;
		// this.pixelPerfect.value[0] = pixelPerfect;
		return this;
	}
}