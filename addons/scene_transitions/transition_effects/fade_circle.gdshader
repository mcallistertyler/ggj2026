shader_type canvas_item;

 uniform float radius : hint_range(0.0, 2.0) = 0.5;
 uniform vec2 center = vec2(0.5, 0.5);
 uniform float edge_softness : hint_range(0.0, 0.1) = 0.0025;
 uniform float aspect_ratio = 1.0;

 void fragment() {
   vec2 uv = UV;

   vec2 corrected_uv = uv;
   corrected_uv.x *= aspect_ratio;

   vec2 corrected_center = center;
   corrected_center.x *= aspect_ratio;

   float dist = distance(corrected_uv, corrected_center);
   float circle = smoothstep(radius - edge_softness, radius + edge_softness, dist);

   COLOR.a *= circle;
 }
