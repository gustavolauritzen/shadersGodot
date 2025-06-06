shader_type spatial;

uniform float metallic : hint_range(0.0, 1.0) = 0.7;
uniform float roughness : hint_range(0.0, 1.0) = 0.5;
uniform vec4 albedo_color = vec4(0.8, 0.8, 0.8, 1.0);

void vertex() {
	
}

void fragment() {
	
    ALBEDO = albedo_color.rgb;
    METALLIC = metallic;
    ROUGHNESS = roughness;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
