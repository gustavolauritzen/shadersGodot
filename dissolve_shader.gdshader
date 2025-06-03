shader_type spatial;
render_mode cull_disabled; // Desabilita o backface culling para ver o interior durante a dissolução

uniform float dissolve_threshold : hint_range(0.0, 1.0) = 0.5; // Controla o nível de dissolução
uniform sampler2D noise_texture :  filter_linear_mipmap; // Textura de ruído para o padrão de dissolução
uniform vec4 edge_color : source_color = vec4(1.0, 0.5, 0.0, 1.0); // Cor da borda da dissolução
uniform float edge_width : hint_range(0.0, 0.1) = 0.02;

varying float noise_val_vertex; // Passa o valor do ruído do vertex para o fragment

void vertex() {
	// Amostra o ruído no vertex shader para usar na deformação e no fragment
	// Usando WORLD_VERTEX_COORDS para que o ruído seja consistente no espaço do mundo
	// Se não tiver WORLD_VERTEX_COORDS (versões mais antigas da Godot), pode usar UV ou VERTEX
	vec3 world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	noise_val_vertex = texture(noise_texture, world_vertex.xy * 0.1 + TIME * 0.05).r; // Anima o ruído

	// Se o vértice estiver abaixo do limiar de dissolução, altera sua normal e um pouco sua posição
	if (noise_val_vertex < dissolve_threshold + edge_width * 2.0) {
		// Alterar normais para um efeito de "desintegração" ou "queima"
		// Faz as normais apontarem para fora do centro do objeto de forma caótica
		vec3 to_center = normalize(VERTEX); // Vetor do vértice para a origem do objeto
		NORMAL = normalize(mix(NORMAL, to_center + vec3(noise_val_vertex * 2.0 - 1.0,
		                                               texture(noise_texture, world_vertex.yz * 0.12 + TIME * 0.06).g * 2.0 - 1.0,
		                                               texture(noise_texture, world_vertex.xz * 0.11 + TIME * 0.04).b * 2.0 - 1.0) * 0.8,
		                                               clamp((dissolve_threshold - noise_val_vertex) / (edge_width * 2.0),0.0,1.0) ));

		// Opcional: pequena alteração de posição para os vértices que estão se dissolvendo
		VERTEX += NORMAL * (dissolve_threshold - noise_val_vertex) * 0.2 * (1.0-smoothstep(dissolve_threshold, dissolve_threshold + edge_width * 0.5, noise_val_vertex));
	}
}

void fragment() {
	// Usa o valor de ruído passado pelo varying
	float noise = noise_val_vertex;

	if (noise < dissolve_threshold) {
		discard; // Descarta o fragmento se estiver abaixo do limiar
	}

	// Adiciona uma borda colorida ao efeito de dissolução
	if (noise < dissolve_threshold + edge_width && noise >= dissolve_threshold) {
		float edge_factor = smoothstep(dissolve_threshold, dissolve_threshold + edge_width, noise);
		ALBEDO = mix(edge_color.rgb, ALBEDO, edge_factor);
		ALPHA = mix(edge_color.a, ALPHA, edge_factor); // Mantém o alfa da cor da borda
		// Poderia alterar METALLIC ou ROUGHNESS aqui também, se desejado para a borda
		ROUGHNESS = mix(0.1, ROUGHNESS, edge_factor); // Borda mais brilhante
	}
	// Se METALLIC ou ROUGHNESS padrão do material forem alterados, isso conta
	// Exemplo: METALLIC = 0.8; (Isto alteraria o atributo padrão)
}