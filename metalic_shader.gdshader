shader_type spatial;

uniform float metallic : hint_range(0.0, 1.0) = 0.9;
uniform float roughness : hint_range(0.0, 1.0) = 0.2;
uniform vec4 albedo_color = vec4(0.8, 0.8, 0.8, 1.0);

void vertex() {
	
}

void fragment() {
	
    ALBEDO = albedo_color.rgb;
    METALLIC = metallic;
    ROUGHNESS = roughness;
}