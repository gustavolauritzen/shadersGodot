shader_type spatial;

uniform float time_scale : hint_range(0.0, 10.0) = 1.0;
uniform sampler2D gradient_texture;

varying vec3 world_pos;

void vertex() {
    // Guarda a posição global do vértice para usar no fragment
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	// Os vértices sao deslocados ao longo do tempo
    float displacement = sin(TIME * time_scale + VERTEX.x) * 0.1;
    VERTEX.y += displacement;
	VERTEX.x += displacement;
	VERTEX.z += displacement;
}

void fragment() {
    // Variavel varying world_pos, para coordenadas da textura
    vec2 uv = world_pos.xz; // mapeamento simples baseado na posição

    // Textura de ruído para modificar a cor
    vec3 noise = texture(gradient_texture, uv).rgb;

    // Cor base que muda com o tempo
    vec3 base_color = vec3(0.8 + 0.7 * sin(TIME * time_scale));

    // Combina a cor base com o ruído
    ALBEDO = base_color * noise;
    ROUGHNESS = 0.3 + 0.2 * noise.r; // roughness afetado pelo ruído
}