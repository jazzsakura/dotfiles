import kitty_custom_shader_types;

static const int SPARKS = 12;
static const int BOUNCES = 3;
static const float GRAVITY = 1800.0;
static const float MIN_SPEED = 260.0;
static const float MAX_SPEED = 620.0;
static const float UPWARD_KICK = 380.0;
static const float STREAK_LENGTH = 0.06;
static const float THICKNESS = 0.9;
static const float MIN_LIFE = 0.6;
static const float MAX_LIFE = 1.1;
static const float BRIGHTNESS = 1.3;
static const float RESTITUTION = 0.6;
static const float FRICTION = 0.85;
static const float FLOOR_CELLS = 2.0;
static const float SPAWN_SPREAD = 1.4;

float
hash(float n) {
    return frac(sin(n * 127.1) * 43758.5453);
}

float
segment_distance(float2 p, float2 a, float2 b, out float along) {
    float2 pa = p - a;
    float2 ba = b - a;
    along = saturate(dot(pa, ba) / max(dot(ba, ba), 0.0001));
    return length(pa - ba * along);
}

public float4
fragment_main(float4 color, KittyTextures t, KittyCustomShaderData d) {
    float age = d.timestamp - d.cursor_trail_change_time;
    float e = d.cursor_trail_prev_edge.y - d.cursor_trail_prev_edge.x;
    if (d.cursor_trail_change_time < 0.0001 || e <= 0.0 || age < 0.0 || age > MAX_LIFE) return color;

    float2 res = float2(d.viewport_size_pixels);
    float2 here = t.pos * res;

    float2 cell_min = float2(d.cursor_trail_prev_edge.x, d.cursor_trail_prev_edge.w) * res;
    float2 cell_max = float2(d.cursor_trail_prev_edge.y, d.cursor_trail_prev_edge.z) * res;
    float2 cell = cell_max - cell_min;
    float2 origin = (cell_min + cell_max) * 0.5;
    float floor_y = cell_min.y - cell.y * FLOOR_CELLS;

    float reach_x = MAX_SPEED * MAX_LIFE + cell.x * SPAWN_SPREAD + 20.0;
    float reach_up = 280.0 + cell.y;
    if (abs(here.x - origin.x) > reach_x) return color;
    if (here.y < floor_y - 6.0 || here.y > origin.y + reach_up) return color;

    float3 spark_color = lerp(d.foreground.rgb, d.cursor_color.rgb, step(0.001, d.cursor_color.a));
    float seed = frac(d.cursor_trail_change_time * 13.37) * 100.0;
    float streak = cell.y * STREAK_LENGTH * 10.0;

    float3 outc = color.rgb;

    for (int i = 0; i < SPARKS; i++) {
        float fi = float(i);
        float life = lerp(MIN_LIFE, MAX_LIFE, hash(fi * 7.3 + seed + 2.0));
        if (age >= life) continue;

        float a = hash(fi * 3.1 + seed) * 6.2831853;
        float speed = lerp(MIN_SPEED, MAX_SPEED, hash(fi * 5.7 + seed + 1.0));
        float2 v = float2(cos(a), sin(a)) * speed;
        v.y += UPWARD_KICK;

        float2 spawn = (float2(hash(fi * 11.3 + seed + 4.0), hash(fi * 13.7 + seed + 5.0)) - 0.5) * cell * SPAWN_SPREAD;
        float2 pos = origin + spawn;
        pos.y = max(pos.y, floor_y + 1.0);

        float rem = age;
        bool done = false;
        for (int b = 0; b < BOUNCES; b++) {
            if (!done) {
                float disc = v.y * v.y + 2.0 * GRAVITY * (pos.y - floor_y);
                float th = (v.y + sqrt(max(disc, 0.0))) / GRAVITY;
                if (rem <= th) {
                    pos.x += v.x * rem;
                    pos.y += v.y * rem - 0.5 * GRAVITY * rem * rem;
                    v.y -= GRAVITY * rem;
                    done = true;
                } else {
                    pos.x += v.x * th;
                    pos.y = floor_y;
                    v.y = -(v.y - GRAVITY * th) * RESTITUTION;
                    v.x *= FRICTION;
                    rem -= th;
                }
            }
        }
        if (!done) {
            pos.x += v.x * rem;
            pos.y = floor_y;
        }

        float2 dir = v / max(length(v), 0.001);
        float k = 1.0 - age / life;
        float2 tail = pos - dir * streak * (0.4 + 0.6 * k);

        float2 lo = min(tail, pos) - 3.0;
        float2 hi = max(tail, pos) + 3.0;
        if (here.x < lo.x || here.x > hi.x || here.y < lo.y || here.y > hi.y) continue;

        float along;
        float dist = segment_distance(here, tail, pos, along);
        float width = THICKNESS * (0.35 + 0.65 * along);
        float edge = smoothstep(width + 0.7, width - 0.3, dist);
        float fade = k * (0.25 + 0.75 * along);

        outc = lerp(outc, saturate(spark_color * BRIGHTNESS), edge * fade);
    }

    return float4(saturate(outc), color.a);
}
