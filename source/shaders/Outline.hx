package shaders;

// TODO: make this shit lmao
class OutlineShader extends flixel.system.FlxAssets.FlxShader
{
	@:glFragmentSource('
	#pragma header

	const float quality = 5.;

	uniform vec3 borderColor;
	uniform float borderSize;
	// uniform bool complex;

	void main()
	{
		// TEMP
		// based on https://www.shadertoy.com/view/XlsXRB
		// edited by redar13 (and stolen from him too :trollface:)
		// + readability by me

		vec4 tex = texture2D(bitmap, openfl_TextureCoordv.xy);

		// vec3 c = tex.rgb;
		// float a = tex.a;
		bool i = bool(step(.5, tex.a) == 1.);

		float d = borderSize;

		float increasement = 1. / quality;

		for (float x = -1.; x <= 1.; x += increasement)
		{
			for (float y = -1.; y <= 1.; y += increasement)
			{
				vec2 o = vec2(x * d, y * d);
				vec2 s = (openfl_TextureCoordv.xy + o / openfl_TextureSize.xy);

				float o_a = texture2D(bitmap, s).a;
				bool o_i = bool(step(.5, o_a) == 1.);

				if (!i && o_i || i && !o_i)
				{
					d = min(d, length(o));
				}
			}
		}

		d = clamp(d, 0., borderSize) / borderSize;

		/*if (i)
		{
			d = -d;
		}*/

		d = 1. - ((i ? -d : d) * .5 + .5);
		// d = 1. - d;

		float border_fade_outer = .2;
		float border_fade_inner = 0.;
		// float border_width = .5;

		float outer = smoothstep(0., .5 - border_fade_outer, d);

		// vec3 temp = vec3(0.);
		vec4 border = mix(vec4(0.), vec4(borderColor, 1.), outer);

		float inner = smoothstep(.5, .5 + border_fade_inner, d);

		gl_FragColor = mix(border, tex, inner);

		// gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
	}')
    public function new(color:FlxColor = 0, borderSize = 2.)
	{
		super();
		this.borderColor.value = [color.redFloat, color.greenFloat, color.blueFloat];
		this.borderSize.value = [borderSize];
		// this.complex.value = [false];
	}
}