shader_type spatial;
render_mode blend_mix, unshaded; // Unshaded para não ser afetado pela luz e blend_mix para transparência

uniform sampler2D noise_texture : source_color, filter_linear_mipmap; // Textura de ruído
uniform float scan_line_speed = 2.0;
uniform float scan_line_width = 0.1;
uniform float glitch_strength = 0.05;
uniform vec4 hologram_color : source_color = vec4(0.3, 0.7, 1.0, 0.7); // Cor e alfa base

varying vec2 uv_mod; // Varying para passar UV modificado

void vertex() {
	// Passa as coordenadas UV para o fragment shader
	// Poderíamos modificar o UV aqui se necessário (ex: para animação de textura no vertex)
	uv_mod = UV;

	// Pequena alteração na posição do vértice para um efeito de "glitch" sutil
	// Usando sin e cos com TIME para criar um movimento irregular e pequeno
	float time_glitch = TIME * 5.0;
	VERTEX.x += sin(time_glitch + VERTEX.y * 10.0) * glitch_strength * 0.1;
	VERTEX.z += cos(time_glitch * 0.7 + VERTEX.x * 8.0) * glitch_strength * 0.08;

	// Opcional: Alterar levemente as normais para distorcer o "brilho" do holograma
	NORMAL += vec3(sin(TIME * 3.0 + VERTEX.x * 5.0) * 0.1, 0.0, cos(TIME * 2.5 + VERTEX.z * 6.0) * 0.1);
	NORMAL = normalize(NORMAL);
}

void fragment() {
	// Amostra a textura de ruído usando o UV passado pela varying
	float noise_value = texture(noise_texture, uv_mod + vec2(0.0, TIME * 0.1)).r; // Anima o ruído no eixo Y

	// Cria efeito de linha de varredura
	float scan_line = mod(uv_mod.y * 10.0 - TIME * scan_line_speed, 1.0); // Multiplicar uv_mod.y aumenta a quantidade de linhas
	float scan_intensity = smoothstep(0.0, scan_line_width, scan_line) - smoothstep(scan_line_width, scan_line_width * 2.0, scan_line);

	// Modula a cor e o alfa com base no ruído e na linha de varredura
	vec4 final_color = hologram_color;
	final_color.a *= (noise_value * 0.5 + 0.5); // Ruído afeta a transparência
	final_color.rgb += scan_intensity * 0.8;   // Linha de varredura mais clara
	final_color.a *= (1.0 - scan_intensity * 0.5); // Linha de varredura pode ser um pouco mais opaca

	// Efeito de "fresnel" para brilho nas bordas
	float fresnel = pow(1.0 - clamp(dot(normalize(VIEW), normalize(NORMAL)), 0.0, 1.0), 2.0);
	final_color.rgb += fresnel * hologram_color.rgb * 0.5;
	final_color.a = clamp(final_color.a + fresnel * 0.2, 0.0, hologram_color.a);

	// Aplica a cor final
	ALBEDO = final_color.rgb;
	ALPHA = final_color.a;
}