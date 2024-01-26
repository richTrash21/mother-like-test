package shaders;

/**
	Hur hur hur hur hur fedy poopybear
**/
class Displacement
{
	public var shader(default, null):DisplacementShader;
	public var factor(get, set):Float;

	public function new()
	{
		#if !flash
		shader = new DisplacementShader();
		shader.factor.value = [0.4];
		#end
	}

	@:noCompletion inline function set_factor(Value:Float):Float
	{
		return #if !flash shader.factor.value[0] = #end Value;
	}

	@:noCompletion inline function get_factor():Float
	{
		return #if !flash shader.factor.value[0] #else 0.0 #end ;
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
	vec2 displace(vec2 coord, vec2 texture)
	{
		if (factor == 0.0)
		{
			return coord;
		}

		float distanceX = distance(coord.x, 0.5);
		float distanceY = distance(coord.y, 0.5);

		float offset = (distanceX * (factor * 0.5)) * distanceY;
		float dir = coord.y > 0.5 ? -1.0 : 1.0;

		return vec2(coord.x, coord.y + distanceX * (offset * 8.0 * dir));
	}
	
	void main()
	{
		vec2 uv = displace(openfl_TextureCoordv, openfl_TextureSize);
		gl_FragColor = flixel_texture2D(bitmap, uv);
	}')
	public function new() { super(); }
}