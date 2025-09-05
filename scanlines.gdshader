shader_type canvas_item;

// Dobbiamo dichiarare esplicitamente che vogliamo usare la texture dello schermo
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

// I parametri per personalizzare l'effetto rimangono identici
uniform float line_density : hint_range(1.0, 10.0) = 2.0;
uniform float line_darkness : hint_range(0.0, 1.0) = 0.75;

void fragment() {
    // Prendiamo il colore del pixel. La sintassi qui non cambia.
    vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);

    // Il resto della logica per calcolare e scurire le linee è identico.
    float y_pos = FRAGCOORD.y;

    if (mod(y_pos, line_density) < 1.0) {
        COLOR = screen_color * vec4(line_darkness, line_darkness, line_darkness, 1.0);
    } else {
        COLOR = screen_color;
    }
}