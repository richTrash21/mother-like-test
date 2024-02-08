package shaders;

/**
	Hur hur hur hur hur fedy poopybear
**/
class Displacement extends util.ShaderUtil.ShaderController<DisplacementShader>
{
	// public var shader(default, null):DisplacementShader;
	public var factor(get, set):Float;

	public function new()
	{
		super();
		exists = active = false;

		shader = new DisplacementShader();
		shader.factor.value = [.4];
	}

	@:noCompletion inline function set_factor(Value:Float):Float
	{
		return shader.factor.value[0] = Value;
	}

	@:noCompletion inline function get_factor():Float
	{
		return shader.factor.value[0];
	}
}

/**
	Port of https://www.youtube.com/watch?v=-Ah8vvXwv5Y with minor abjustments
**/
class DisplacementShader extends flixel.system.FlxAssets.FlxShader
{
	@:glFragmentSource('
	#pragma header

	/**  How much you want this image to be displaced?  **/
	uniform float factor;

	/**  Function that calculates FNAF like sprite displacement  **/
	vec2 displace(vec2 coord /*, vec2 texture*/ )
	{
		if (factor == 0.)
		{
			return coord;
		}

		float distanceX = distance(coord.x, .5);
		float distanceY = distance(coord.y, .5);

		float offset = (distanceX * (factor * .5)) * distanceY;
		float dir = coord.y > .5 ? -1. : 1.;

		coord.y += distanceX * (offset * 8. * dir);
		return coord;
	}
	
	void main()
	{
		vec2 uv = displace(openfl_TextureCoordv /*, openfl_TextureSize*/ );
		gl_FragColor = flixel_texture2D(bitmap, uv);
	}')
	public function new() { super(); }
}