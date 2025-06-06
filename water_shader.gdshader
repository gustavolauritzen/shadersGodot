shader_type spatial;

uniform float wave_frequency = 10.0;
uniform float wave_amplitude = 0.1;
uniform float speed = 1.0;
uniform float metallic_value : hint_range(0.0, 1.0) = 1.0;
uniform float roughness_value : hint_range(0.0, 1.0) = 1.0; // Atributo padrão alterado

varying vec3 world_pos;

void vertex() {
	// Passa a posição mundial do vértice para o fragment shader
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	// Altera a posição dos vértices (Y) com base no seno e cosseno e no tempo
	VERTEX.y += sin(VERTEX.x * wave_frequency + TIME * speed) * wave_amplitude;
	VERTEX.y += cos(VERTEX.z * wave_frequency * 0.5 + TIME * speed * 0.8) * wave_amplitude * 0.5; // Segunda onda para mais variação

	// Recalcula as normais após a deformação para iluminação correta (simplificado)
	vec3 tangent = normalize(cross(NORMAL, vec3(0.0, 0.0, 1.0)));
	vec3 binormal = normalize(cross(NORMAL, vec3(1.0, 0.0, 0.0)));
	vec3 new_normal_approx = cross(tangent, binormal);

	// Adiciona uma pequena perturbação às normais baseada no tempo para simular movimento da superfície
	NORMAL = normalize(mix(NORMAL, new_normal_approx + vec3(
		sin(VERTEX.x * wave_frequency * 2.0 + TIME * speed * 1.5) * 0.2,
		0.0, // Mantém a normal principalmente para cima, mas com variação
		cos(VERTEX.z * wave_frequency * 1.5 + TIME * speed * 1.2) * 0.2
	), 0.3));
}

void fragment() {
	// Altera o atributo padrão ROUGHNESS
	ROUGHNESS = roughness_value;
	METALLIC = metallic_value;
	ALBEDO = vec3(0.2, 0.4, 0.8); // Cor azulada para a água

	// Adiciona um brilho sutil com base na posição e no tempo
	float fresnel_effect = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	EMISSION = ALBEDO * fresnel_effect * 0.3 * (0.5 + sin(TIME * 2.0 + world_pos.x * 5.0) * 0.5);
}