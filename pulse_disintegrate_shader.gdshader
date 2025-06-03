shader_type spatial;
render_mode blend_add, unshaded; // blend_add para brilho aditivo, unshaded para controle total da emissão

uniform float pulse_speed = 2.0; // Velocidade da pulsação
uniform float pulse_strength = 0.5; // Força do brilho da pulsação
uniform vec4 pulse_color : source_color = vec4(0.0, 1.0, 1.0, 1.0); // Cor do brilho
uniform float disintegrate_amount : hint_range(0.0, 1.0) = 0.0; // Uniform para controlar a desintegração/vibração
uniform float normal_distortion_strength = 0.5; // Força da distorção das normais
uniform float metallic_override : hint_range(0.0, 1.0) = 0.0; // Atributo padrão METALLIC
uniform float roughness_override : hint_range(0.0, 1.0) = 0.5; // Atributo padrão ROUGHNESS

uniform sampler2D noise_texture : source_color, filter_linear_mipmap; // <--- NOVA LINHA: Textura de ruído

varying vec3 vertex_normal; // Passa a normal original do vértice
varying vec3 view_dir_ws; // Passa a direção do vetor de visão no espaço do mundo

void vertex() {
	// Guarda a normal original do vértice
	vertex_normal = NORMAL;

	// Calcula a posição do vértice no espaço do mundo
	vec3 world_vertex_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	// Obtenha a direção do vetor de visão no espaço do mundo
	view_dir_ws = normalize(CAMERA_POSITION_WORLD - world_vertex_pos);

	// Amostra a textura de ruído
	// Usamos as coordenadas do vértice (ou UV se preferir) para amostrar o ruído
	// Adicionamos TIME para animar o ruído
	float noise_val = texture(noise_texture, world_vertex_pos.xy * 0.1 + TIME * 0.05).r * 2.0 - 1.0; // Amostra o ruído e mapeia para -1 a 1

	// Deformação da posição dos vértices baseada no tempo e no uniform de desintegração
	// Altera a posição do vértice
	VERTEX += NORMAL * noise_val * disintegrate_amount * 0.1; // Sutil empurrão ao longo da normal
	VERTEX += cross(NORMAL, vec3(sin(TIME * 3.0), cos(TIME * 2.5), sin(TIME * 3.5))) * disintegrate_amount * 0.05; // Pequeno movimento lateral

	// Altera as normais dos vértices para criar um efeito de desintegração/vibração
	// Mixamos a normal original com uma normal perturbada
	vec3 perturbed_normal = NORMAL + vec3(
		sin(TIME * 4.0 + VERTEX.x * 10.0) * noise_val,
		cos(TIME * 3.0 + VERTEX.y * 10.0) * noise_val,
		sin(TIME * 5.0 + VERTEX.z * 10.0) * noise_val
	) * normal_distortion_strength * disintegrate_amount;

	NORMAL = normalize(mix(NORMAL, perturbed_normal, disintegrate_amount)); // Mais distorção com maior disintegrate_amount
}

void fragment() {
	// Calcula o efeito Fresnel para o brilho nas bordas (brilho pulsante)
	float fresnel = pow(1.0 - clamp(dot(normalize(NORMAL), view_dir_ws), 0.0, 1.0), 3.0);

	// Calcula a intensidade da pulsação com base no tempo
	float pulse = (sin(TIME * pulse_speed) * 0.5 + 0.5) * pulse_strength;

	// Define a cor do ALBEDO (cor base do objeto)
	ALBEDO = vec3(0.1, 0.2, 0.3); // Uma cor escura para destacar o brilho

	// Aplica o brilho pulsante à emissão
	EMISSION = pulse_color.rgb * (fresnel + pulse); // Brilho aditivo

	// Controla a opacidade (ALPHA) para uma leve transparência ou para fazer o objeto "sumir" com disintegrate_amount
	ALPHA = 1.0 - (disintegrate_amount * 0.8); // Objeto mais transparente quanto mais "desintegrado"

	// Altera atributos padrão da Godot
	METALLIC = metallic_override;
	ROUGHNESS = roughness_override;
}