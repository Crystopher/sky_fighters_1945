shader_type canvas_item;

// Uniforms: i nostri "potenziometri" per controllare l'effetto
uniform vec4 glow_color : source_color = vec4(0.0, 0.7, 1.0, 1.0); // Azzurro brillante
uniform float glow_strength : hint_range(0.0, 5.0) = 0.0; // Intensità del glow (lo animeremo)
uniform float glow_size : hint_range(0.0, 50.0) = 6.0;  // Dimensione in PIXEL del glow (questo è il controllo che volevi!)
uniform float pulse_speed : hint_range(0.0, 10.0) = 3.0;
uniform float pulse_strength : hint_range(0.0, 1.0) = 0.3;

void fragment() {
    vec4 base_color = texture(TEXTURE, UV);
    float max_alpha = 0.0;

    // Numero di campioni da prendere in un cerchio attorno al pixel
    const int SAMPLES = 8;

    for (int i = 0; i < SAMPLES; i++) {
        // Calcoliamo l'angolo per questo campione
        float angle = float(i) / float(SAMPLES) * TAU; // TAU è 2*PI, quindi un cerchio completo

        // Campioniamo la texture a una certa distanza (glow_size) in quella direzione
        vec2 offset = vec2(cos(angle), sin(angle)) * TEXTURE_PIXEL_SIZE * glow_size;
        max_alpha = max(max_alpha, texture(TEXTURE, UV + offset).a);
    }

    // Calcoliamo il fattore di pulsazione
    float pulse = (sin(TIME * pulse_speed) * 0.5 + 0.5) * pulse_strength + (1.0 - pulse_strength);

    // Calcoliamo la forza finale del glow, sottraendo l'alpha del colore base
    // per evitare di colorare l'interno dello sprite.
    float glow_factor = max(0.0, max_alpha - base_color.a) * glow_strength * pulse;

    // Mescoliamo il colore base con il colore del glow
    COLOR = mix(base_color, glow_color, glow_factor);
}