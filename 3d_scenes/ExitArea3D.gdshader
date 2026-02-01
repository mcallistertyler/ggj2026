shader_type spatial;
  render_mode unshaded, cull_disabled, blend_mix;

  uniform vec4 particle_color : source_color = vec4(1.0, 0.9, 0.5, 0.8);
  uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 0.8);
  uniform float speed : hint_range(0.1, 2.0) = 0.5;
  uniform float density : hint_range(1.0, 20.0) = 8.0;
  uniform float outline_thickness : hint_range(0.01, 0.15) = 0.05;

  float hash(vec2 p) {
      return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
  }

  void fragment() {
      vec2 uv = UV * density;
      vec2 cell = floor(uv);
      vec2 local = fract(uv);

      float core_alpha = 0.0;
      float outline_alpha = 0.0;

      for (int y = -1; y <= 1; y++) {
          for (int x = -1; x <= 1; x++) {
              vec2 neighbor = vec2(float(x), float(y));
              vec2 cell_id = cell + neighbor;

              float rand1 = hash(cell_id);
              float rand2 = hash(cell_id + 100.0);

              vec2 particle_pos = vec2(rand1, rand2);
              particle_pos.y += sin(TIME * speed + rand1 * 6.28) * 0.3;
              particle_pos.x += cos(TIME * speed * 0.7 + rand2 * 6.28) * 0.1;

              float dist = length(local - neighbor - particle_pos);
              float size = 0.05 + rand1 * 0.05;
              float outer_size = size + outline_thickness;

              // Core particle
              float particle = smoothstep(size, 0.0, dist);
              // Outline ring (outer edge minus inner core)
              float outline = smoothstep(outer_size, outer_size - 0.02, dist) * smoothstep(size * 0.5, size, dist);

              float flicker = 0.5 + 0.5 * sin(TIME * 3.0 + rand1 * 6.28);
              particle *= flicker;
              outline *= flicker;

              core_alpha += particle;
              outline_alpha += outline;
          }
      }

      // Blend outline behind the core
      vec3 final_color = mix(outline_color.rgb, particle_color.rgb, clamp(core_alpha, 0.0, 1.0));
      float final_alpha = clamp(core_alpha * particle_color.a + outline_alpha * outline_color.a, 0.0, 1.0);

      ALBEDO = final_color;
      ALPHA = final_alpha;
  }