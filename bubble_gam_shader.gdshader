shader_type spatial;

uniform float pulse_strength : hint_range(0.0, 2.0) = 0.07;
uniform float pulse_speed : hint_range(0.0, 10.0) = 3.0;

varying vec3 world_pos;

void vertex() {
    // Salva a posição global para usar no fragment
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

    // Calcula direção do centro para o vértice
    vec3 direction = normalize(VERTEX);

    // Cria um fator de expansão baseado no tempo (pulsação)
    float pulse = sin(TIME * pulse_speed) * pulse_strength;

    // Desloca os vértices para fora, radialmente
    VERTEX += direction * pulse;

    // Ajusta a normal: simula que o vértice foi empurrado nessa direção
    NORMAL = normalize(NORMAL + direction * pulse * 5.0);
    // Multiplicador usado para intensificar o efeito de inclinação da normal
}

void fragment() {
    // Coloração baseada na distância do vértice ao centro
    float intensity = length(world_pos) * 0.2;
    ALBEDO = vec3(0.8, 0.2, 0.1) + intensity;
}
