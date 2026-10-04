import kitty_custom_shader_types;

bool
inside_trail_quad(float2 uv, float2 c0, float2 c1, float2 c2, float2 c3) {
    float2 e0 = c1 - c0;
    float2 e1 = c2 - c1;
    float2 e2 = c3 - c2;
    float2 e3 = c0 - c3;
    float s0 = e0.x * (uv.y - c0.y) - e0.y * (uv.x - c0.x);
    float s1 = e1.x * (uv.y - c1.y) - e1.y * (uv.x - c1.x);
    float s2 = e2.x * (uv.y - c2.y) - e2.y * (uv.x - c2.x);
    float s3 = e3.x * (uv.y - c3.y) - e3.y * (uv.x - c3.x);
    return s0 <= 0.0 && s1 <= 0.0 && s2 <= 0.0 && s3 <= 0.0;
}

public float4
fragment_main(float4 color, KittyTextures t, KittyCustomShaderData d) {
    float opacity = d.cursor_trail_color.a;
    if (opacity <= 0.0) return color;

    float2 uv = t.pos;

    float2 c0 = float2(d.cursor_trail_corners_x.x, d.cursor_trail_corners_y.x);
    float2 c1 = float2(d.cursor_trail_corners_x.y, d.cursor_trail_corners_y.y);
    float2 c2 = float2(d.cursor_trail_corners_x.z, d.cursor_trail_corners_y.z);
    float2 c3 = float2(d.cursor_trail_corners_x.w, d.cursor_trail_corners_y.w);

    if (!inside_trail_quad(uv, c0, c1, c2, c3)) return color;

    float inside_cursor =
        step(d.cursor_trail_edge.x, uv.x) * step(uv.x, d.cursor_trail_edge.y) * step(d.cursor_trail_edge.w, uv.y) * step(uv.y, d.cursor_trail_edge.z);
    opacity *= 1.0 - inside_cursor;
    if (opacity <= 0.0) return color;

    return float4(lerp(color.rgb, d.cursor_trail_color.rgb, opacity), color.a);
}
