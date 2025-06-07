extern float elapsed = 10;

vec2 radialDistortion(vec2 coord, float dist)
{
    vec2 cc = coord - 0.5;
    dist = dot(cc, cc) * dist + cos(elapsed * 0.3) * 0.01;
    return (coord + cc * (1.0 + dist) * dist);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec2 tcr = radialDistortion(texture_coords, 0.22) + vec2(0.001, 0);
    vec2 tcg  = radialDistortion(texture_coords, 0.21);
    vec2 tcb = radialDistortion(texture_coords, 0.20) - vec2(0.001, 0);
    vec4 res = vec4(Texel(texture, tcr).r, Texel(texture, tcg).g, Texel(texture, tcb).b, 1)
        - cos(tcg.y * 128. * 3.142 * 2) * 0.01
        - sin(tcg.x * 128. * 3.142 * 2) * 0.01;
    return res * Texel(texture, tcg).a;
}
