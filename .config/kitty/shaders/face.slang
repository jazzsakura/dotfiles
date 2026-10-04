import kitty_custom_shader_types;

static const float FACE_RADIUS = 36.0;
static const float MARGIN = 40.0;
static const float SIDE_MARGIN = 40.0;
static const float HOP_HEIGHT = 22.0;
static const float BOUNCE_SPEED = 9.0;
static const float BOUNCE_DECAY = 3.2;
static const float BLINK_EVERY = 4.5;
static const float WINK_EVERY = 11.0;

float
cover(float sd) {
    return smoothstep(0.75, -0.75, sd);
}

float
box_sd(float2 p, float2 half_size, float radius) {
    float2 q = abs(p) - half_size + radius;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
}

public float4
fragment_main(float4 color, KittyTextures t, KittyCustomShaderData d) {
    float2 res = float2(d.viewport_size_pixels);
    float2 here = t.pos * res;
    float R = FACE_RADIUS;
    float cx = res.x - SIDE_MARGIN - R;

    if (abs(here.x - cx) > R * 1.6) return color;
    if (here.y < MARGIN - 4.0 || here.y > MARGIN + R * 2.4 + HOP_HEIGHT + 6.0) return color;

    float age = 100.0;
    if (d.cursor_trail_change_time > 0.0001) age = max(d.timestamp - d.cursor_trail_change_time, 0.0);

    float amp = exp(-age * BOUNCE_DECAY) * step(age, 2.5);
    float sn = abs(sin(age * BOUNCE_SPEED));
    float hop = HOP_HEIGHT * amp * sn;
    float land = (1.0 - smoothstep(0.0, 0.3, sn)) * amp;
    float sy = 1.0 - 0.28 * land + 0.1 * amp * smoothstep(0.3, 1.0, sn);
    float sx = rsqrt(sy);

    float2 c = float2(cx, MARGIN + R * sy + hop);

    float2 target = d.mouse_pos.xy * res;
    float mouse_dist = length(target - c);

    float excite = exp(-age * 2.5);
    float sleepy = smoothstep(6.0, 10.0, age);
    float curious = 1.0 - smoothstep(R * 2.0, R * 6.0, mouse_dist);

    float surprise = 1.0 - smoothstep(0.05, 0.3, age);
    float happy = smoothstep(0.1, 0.4, age) * exp(-max(age - 0.4, 0.0) * 0.8);
    float yawn = sleepy * pow(saturate(sin(d.timestamp * 0.8)), 6.0);

    float ph = frac(d.timestamp / BLINK_EVERY);
    float blink = saturate(1.0 - abs(ph - 0.97) / 0.03);
    float open = max(1.0 - blink, 0.08);
    open *= 1.0 - 0.7 * yawn;

    float wp = frac((d.timestamp + 3.0) / WINK_EVERY);
    float wink = saturate(1.0 - abs(wp - 0.5) / 0.025) * (1.0 - sleepy);

    float widen = 1.0 + 0.18 * excite + 0.12 * curious + 0.25 * surprise;
    float lid = 0.5 * sleepy * (1.0 - curious);
    float slant = 0.25 * sleepy;

    float3 face_col = d.cursor_color.rgb;
    float3 eye_col = d.background.rgb;
    float3 blush_col = lerp(face_col, float3(1.0, 0.45, 0.55), 0.55);

    float3 outc = color.rgb;

    float2 q = (here - c) / float2(sx, sy);
    float sd_face = length(q) - R;
    float face_mask = cover(sd_face * min(sx, sy));
    outc = lerp(outc, face_col, face_mask);

    float blush_amt = saturate(happy * 0.9 + surprise * 0.3);
    for (int k = 0; k < 2; k++) {
        float bs = (k == 0) ? -1.0 : 1.0;
        float sd_b = length(q - float2(bs * 0.58 * R, -0.18 * R)) - 0.14 * R;
        outc = lerp(outc, blush_col, cover(sd_b) * blush_amt * cover(sd_face + 2.0));
    }

    float mouth_open = saturate(amp * sn * 1.2 + surprise * 0.6 + yawn + curious * 0.3 * (1.0 - sleepy));
    float smile = 0.5 + 1.2 * happy - 0.6 * sleepy;

    float2 pm = q - float2(0.0, -0.45 * R);
    float mw = 0.26 * R * (1.0 + 0.3 * happy);
    float mx = pm.x / mw;
    float y0 = smile * 0.12 * R * (mx * mx - 0.5);
    float sd_line = max(abs(pm.y - y0) * 0.8 - 0.045 * R, abs(pm.x) - mw);

    float ew = 0.13 * R + 0.06 * R * mouth_open;
    float eh = 0.02 * R + 0.17 * R * mouth_open;
    float sd_o = (length(pm / float2(ew, eh)) - 1.0) * min(ew, eh);

    float mouth = max(cover(sd_line) * (1.0 - mouth_open), cover(sd_o) * smoothstep(0.05, 0.2, mouth_open));
    outc = lerp(outc, eye_col, mouth * cover(sd_face + 2.0));

    for (int i = 0; i < 2; i++) {
        float s = (i == 0) ? -1.0 : 1.0;
        float2 ec = float2(s * 0.3 * R, 0.1 * R);

        float eye_open = open;
        if (i == 1) eye_open = max(open * (1.0 - wink), 0.08);

        float2 half_size = float2(0.15 * R * (1.0 + 0.1 * excite), 0.3 * R * widen * eye_open);

        float2 dv = (target - c) - ec;
        float len = length(dv);
        float2 off = dv / max(len, 0.001) * 0.1 * R * saturate(len / (R * 3.0));

        float2 p = q - ec - off;
        float sd_eye = box_sd(p, half_size, 0.04 * R);

        float lid_edge = half_size.y * (1.0 - 2.0 * lid);
        float sd_lid = p.y - lid_edge - s * slant * p.x;
        sd_eye = max(sd_eye, sd_lid);

        float cheek = 0.55 * happy;
        float bot_edge = -half_size.y + 2.0 * half_size.y * cheek;
        sd_eye = max(sd_eye, bot_edge - p.y);

        float eye = cover(sd_eye) * cover(sd_face + 2.0);
        outc = lerp(outc, eye_col, eye);

        float raise = 0.06 * R * curious + 0.1 * R * surprise + 0.04 * R * happy - 0.08 * R * sleepy;
        float tilt = 0.3 * sleepy - 0.15 * happy - 0.1 * curious;
        float2 pb = q - (ec + float2(0.0, 0.5 * R + raise));
        pb.y -= s * tilt * pb.x;
        float sd_brow = box_sd(pb, float2(0.17 * R, 0.025 * R), 0.02 * R);
        float brow_vis = saturate(0.35 + 0.65 * max(max(curious, surprise), max(happy, sleepy)));
        outc = lerp(outc, eye_col, cover(sd_brow) * cover(sd_face + 2.0) * brow_vis);
    }

    return float4(saturate(outc), color.a);
}
