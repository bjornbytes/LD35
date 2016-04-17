extern vec4 color;

vec4 effect(vec4 _, Image texture, vec2 texture_coords, vec2 screen_coords) {
  vec4 result = Texel(texture, texture_coords);
  return vec4(color.rgb, result.a * color.a);
}
