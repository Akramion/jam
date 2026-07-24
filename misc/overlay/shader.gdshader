shader_type canvas_item;

uniform sampler2D screen_texture :
	hint_screen_texture,
	filter_nearest;

uniform float curvature = 0.035;
uniform float scanline_strength = 0.10;
uniform float noise_strength = 0.025;
uniform float chromatic_aberration = 0.0015;
uniform float flicker_strength = 0.025;
uniform float vignette_strength = 0.45;

uniform float tracking_strength = 0.006;
uniform float tracking_speed = 0.35;

float random(vec2 uv) {
	return fract(
		sin(dot(uv, vec2(12.9898, 78.233)))
		* 43758.5453
	);
}

void fragment() {
	vec2 uv = SCREEN_UV;

	// Искривление экрана старого телевизора
	vec2 centered_uv = uv * 2.0 - 1.0;
	float distance_from_center = dot(centered_uv, centered_uv);

	centered_uv *= 1.0 + curvature * distance_from_center;
	uv = centered_uv * 0.5 + 0.5;

	// Плавающая горизонтальная полоса VHS
	float tracking_position = fract(TIME * tracking_speed);

	float tracking_line = smoothstep(
		0.035,
		0.0,
		abs(uv.y - tracking_position)
	);

	uv.x += tracking_line * tracking_strength;

	// Дрожание отдельных горизонтальных строк
	float horizontal_jitter = (
		random(
			vec2(
				floor(uv.y * 240.0),
				floor(TIME * 18.0)
			)
		) - 0.5
	) * 0.0012;

	uv.x += horizontal_jitter;

	bool outside_screen =
		uv.x < 0.0 ||
		uv.x > 1.0 ||
		uv.y < 0.0 ||
		uv.y > 1.0;

	if (outside_screen) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else {
		// Разъезд цветовых каналов
		float red = texture(
			screen_texture,
			uv + vec2(chromatic_aberration, 0.0)
		).r;

		float green = texture(
			screen_texture,
			uv
		).g;

		float blue = texture(
			screen_texture,
			uv - vec2(chromatic_aberration, 0.0)
		).b;

		vec3 color = vec3(red, green, blue);

		// Горизонтальные строки
		vec2 viewport_size = 1.0 / SCREEN_PIXEL_SIZE;

		float scanline = sin(
			uv.y * viewport_size.y * 3.14159265
		);

		color *= 1.0 - scanline_strength
			* (scanline * 0.5 + 0.5);

		// Аналоговый шум
		float noise = random(
			uv * viewport_size
			+ vec2(TIME * 40.0, -TIME * 27.0)
		);

		color += (noise - 0.5) * noise_strength;

		// Лёгкое мерцание яркости
		float flicker =
			sin(TIME * 35.0) * flicker_strength;

		color += flicker;

		// Затемнение по краям
		vec2 vignette_uv = uv * (1.0 - uv.yx);

		float vignette =
			vignette_uv.x
			* vignette_uv.y
			* 15.0;

		vignette = pow(
			clamp(vignette, 0.0, 1.0),
			vignette_strength
		);

		color *= vignette;

		COLOR = vec4(color, 1.0);
	}
}