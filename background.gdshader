
shader_type canvas_item;
render_mode unshaded;

uniform vec4 selected_color : source_color;
uniform vec4 highlight_color : source_color = vec4(1.0, 0.85, 0.1, 1.0);
uniform vec4 border_color : source_color = vec4(1.0, 0.65, 0.05, 1.0);

uniform bool has_selection = false;
uniform float color_tolerance = 0.02;

void fragment() {
    vec4 province = texture(TEXTURE, UV);

    vec4 result = vec4(0.0);

    bool selected = province.a > 0.0 &&
        distance(province.rgb, selected_color.rgb) < color_tolerance;

    if (has_selection && selected) {

        // Detect the edge of the selected province
        bool edge = false;

        for (int x = -1; x <= 1; x++) {
            for (int y = -1; y <= 1; y++) {

                if (x == 0 && y == 0) {
                    continue;
                }

                vec2 offset = vec2(float(x), float(y)) * TEXTURE_PIXEL_SIZE;
                vec2 sample_uv = clamp(UV + offset, vec2(0.0), vec2(1.0));

                vec4 neighbor = texture(TEXTURE, sample_uv);

                if (neighbor.a < 0.1 ||
                    distance(neighbor.rgb, selected_color.rgb) >= color_tolerance) {
                    edge = true;
                }
            }
        }

        // Keep the pulsing glow
        float pulse = 0.5 + 0.5 * sin(TIME * 2.5);

        if (edge) {
            result = vec4(border_color.rgb, 0.95);
        } else {
            result = vec4(
                highlight_color.rgb,
                0.25 + pulse * 0.25
            );
        }
    }

    COLOR = result;
}
