// Ghostty Shader: Cyberpunk 2077 "Deep Breach" (Retro CRT Edition)
// High-contrast red UI with rare AI breaches and heavy analog CRT characteristics.

// --- Configuration ---
#define SCANLINE_INTENSITY 0.12
#define SCANLINE_COUNT 1000.0
#define BLOOM_INTENSITY 1.6
#define UI_TINT vec3(1.0, 0.02, 0.05)
#define CURVATURE 0.08
#define VIGNETTE_STRENGTH 0.55

// --- Helpers ---
float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

// CRT Screen Curvature
vec2 curve(vec2 uv) {
    uv = uv * 2.0 - 1.0;
    vec2 offset = abs(uv.yx) / vec2(6.0, 4.0);
    uv = uv + uv * offset * offset * CURVATURE;
    uv = uv * 0.5 + 0.5;
    return uv;
}

// Procedural "Code" Snippet (Tiny, rare, tech bursts)
vec3 getCodeSnippet(vec2 uv, float time, float seed) {
    float aspect = iResolution.x / iResolution.y;
    vec2 grid = vec2(180.0 * aspect, 90.0);
    vec2 st = uv * grid;
    vec2 id = floor(st);
    float occurrence = step(0.96, hash(vec2(floor(time * 0.3), seed)));
    id.y += floor(time * 40.0 * (hash(vec2(seed)) - 0.5));
    float lineHash = hash(vec2(id.y, seed));
    float charActive = step(floor(lineHash * 5.0) * 4.0, id.x) * step(id.x, 10.0 + lineHash * 30.0);
    float charMask = step(0.5, hash(id + seed)) * step(0.2, hash(fract(st) + id));
    return UI_TINT * charActive * charMask * occurrence * 0.15;
}

// Ultra-Subtle Streamer Layer
vec3 getStreamerLayer(vec2 uv, float time, float density, float speed, float seed, float jitter) {
    float aspect = iResolution.x / iResolution.y;
    vec2 st = uv * vec2(density * aspect, 1.0);
    float id = floor(st.x);
    float fst_x = fract(st.x) - 0.5;
    float h = hash(vec2(id, seed));
    float y = fract(uv.y + time * speed * (0.8 + h * 0.4) + h * 10.0 + (jitter * hash(vec2(id, time))));
    float head = smoothstep(0.5, 0.1, length(vec2(fst_x * 5.0, (y - 1.0) * 35.0)));
    float trail = pow(y, 30.0 + h * 10.0) * smoothstep(0.5, 0.35, abs(fst_x * 2.0));
    float mask = step(0.92, hash(vec2(id, seed + 1.23)));
    return UI_TINT * (head + trail) * mask * 0.015;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    float time = iTime;
    
    // --- 0. Dual-Cycle Glitch System ---
    // A: Regular Glitch (Every ~10s)
    float gWin = floor(time / 10.0);
    float gTrig = gWin * 10.0 + 2.0 + hash(vec2(gWin, 1.1)) * 6.0;
    float isGlitch = step(gTrig, time) * step(time, gTrig + 0.3);
    float glitchJitter = isGlitch * step(0.3, hash(vec2(time * 35.0, 3.1)));
    
    // --- 1. CRT Curvature & Borders ---
    vec2 curvedUV = curve(uv);
    if (curvedUV.x < 0.0 || curvedUV.x > 1.0 || curvedUV.y < 0.0 || curvedUV.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0); return;
    }

    // --- 2. Background Void ---
    vec3 bg = vec3(0.001, 0.0, 0.0); 
    bg += getStreamerLayer(curvedUV, time, 180.0, 0.04, 1.0, glitchJitter);
    bg += getStreamerLayer(curvedUV, time, 90.0, 0.015, 2.0, glitchJitter);
    bg += getCodeSnippet(curvedUV, time, 3.0) * (1.0 + glitchJitter * 2.5);
    
    // HUD Brackets
    vec2 q = abs(curvedUV - 0.5) * 2.0;
    float hud = step(0.93, q.x) * step(0.998, q.y) + step(0.998, q.x) * step(0.93, q.y);
    bg += UI_TINT * hud * (0.4 + glitchJitter * 0.8);
    
    // --- 3. Terminal Text (CRT Sharpness & Ghosting) ---
    float dist = distance(curvedUV, vec2(0.5));
    float aberration = pow(dist, 4.0) * 0.0025 + (glitchJitter * 0.01); 
    vec3 text;
    text.r = texture(iChannel0, curvedUV + vec2(aberration, 0.0)).r;
    text.g = texture(iChannel0, curvedUV).g;
    text.b = texture(iChannel0, curvedUV - vec2(aberration, 0.0)).b;
    
    // Retro Ghosting (Slight horizontal bleed)
    vec3 ghost = texture(iChannel0, curvedUV - vec2(0.002, 0.0)).rgb * 0.3;
    text += ghost * UI_TINT;

    vec3 finalColor = text + bg;
    
    // --- 4. Post-Processing (Pure Analog Feel) ---
    // RGB Shadow Mask (Aperture Grille)
    float mask = sin(fragCoord.x * 1.5) * 0.1 + 0.9;
    finalColor *= mask;

    // Heavy Scanlines
    float scanline = sin(curvedUV.y * SCANLINE_COUNT) * 0.08 + 0.92;
    finalColor *= scanline;
    
    // Red Bloom
    vec3 bloom = vec3(0.0);
    float b_offset = 0.0008;
    bloom += texture(iChannel0, curvedUV + vec2(b_offset, 0.0)).rgb;
    bloom += texture(iChannel0, curvedUV - vec2(b_offset, 0.0)).rgb;
    finalColor += bloom * UI_TINT * (BLOOM_INTENSITY + glitchJitter) * 0.3;

    // Red Tinted CRT Vignette
    float vig = curvedUV.x * curvedUV.y * (1.0 - curvedUV.x) * (1.0 - curvedUV.y);
    vig = pow(16.0 * vig, 0.25); // Sharper falloff
    
    // Create a red glow at the edges
    vec3 vigColor = mix(UI_TINT * 0.15, vec3(1.0), vig);
    finalColor *= vigColor * (1.0 - dist * VIGNETTE_STRENGTH);

    fragColor = vec4(finalColor, 1.0);
}
