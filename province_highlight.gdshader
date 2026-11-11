
shader_type canvas_item;
render_mode unshaded;

uniform vec4 selected_color : source_color;
uniform vec4 highlight_color : source_color = vec4(1.0, 0.85, 0.1, 1.0);
uniform vec4 border_color : source_color = vec4(0.55, 0.32, 0.04, 1.0);

uniform bool has_selection = false;
uniform float color_tolerance = 0.02;

uniform float glow_strength = 0.65;
uniform float pulse_speed = 2.5;

void fragment() {
    vec4 original = texture(TEXTURE, UV);

    if (has_selection && distance(original.rgb, selected_color.rgb) < color_tolerance) {

        // Pulsing gold glow
        float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);

        original.rgb = mix(
            original.rgb,
            highlight_color.rgb,
            glow_strength * pulse
        );

        // Detect thicker province border
        vec2 texel = TEXTURE_PIXEL_SIZE;
        bool edge = false;

        for (int x = -5; x <= 5; x++) {
            for (int y = -5; y <= 5; y++) {

                if (x == 0 && y == 0) {
                    continue;
                }

                vec2 offset = vec2(float(x), float(y)) * texel;
                vec4 neighbor = texture(TEXTURE, UV + offset);

                if (distance(neighbor.rgb, selected_color.rgb) >= color_tolerance) {
                    edge = true;
                }
            }
        }

        // Dark gold border
        if (edge) {
            original.rgb = border_color.rgb;
        }
    }

    COLOR = original * COLOR;
}
