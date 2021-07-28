// Frad LEE @ 2021 
// Base on https://www.shadertoy.com/view/flfGW8

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float rand(vec2 p) {
	return fract(sin(dot(p, vec2(12.543,514.123)))*4732.12);
}

// noise
float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  f = f*f*(3.0-2.0*f);
  float n = mix(mix(rand(i + vec2(0.0,0.0)), rand(i + vec2(1.0,0.0)), f.x),
            mix(rand(i + vec2(0.0,1.0)), rand(i + vec2(1.0,1.0)), f.x), f.y);
  return n;
}

// zoom
vec2 zoom(vec2 _st, float _zoom){
	_st *= _zoom;
  return fract(_st);
}

// brightness
float b(float x) {
  return clamp(x, 0.0, 1.0);
}

float lerp(float start, float end, float fraction) {
    return start + ((end - start) * fraction);
}

// halftone
// From https://github.com/genekogan/Processing-Shader-Examples/blob/master/TextureShaders/data/halftone.glsl
// and
// https://codepen.io/cmalven/pen/mMrEbV Not working now...
vec3 halftone(vec2 st, float s, vec3 col) {
    float pixelSize = s;
	
	float dx = mod(st.x, pixelSize) - pixelSize*0.5;
	float dy = mod(st.y, pixelSize) - pixelSize*0.5;
  float d = min(dx, dy);

	st.x += d ;
	st.y += d;
	float bright = col.r  + col.g;
	
	float dist = sqrt(dx*dx + dy*dy);
	float rad = bright * pixelSize * 0.4;
	float m = step(dist, rad);

	return mix(col,vec3(1.0), m);
}

vec3 gradient(vec2 st, vec3 beginColor, vec3 endColor) {
  return vec3(
         lerp(beginColor.x, endColor.x, st.x),
         lerp(beginColor.y, endColor.y, st.x),
         lerp(beginColor.z, endColor.z, st.x));
}

void main(){
  float n = 100.0;

  vec2 uv = gl_FragCoord.xy/u_resolution.xy; 

  vec2 uvg = (gl_FragCoord.xy - u_resolution) / max(u_resolution.x, u_resolution.y); // fixed uv

  float mouse = u_mouse.x/u_resolution.x*u_mouse.y/u_resolution.y; // mouse

  // make uv abstracted
  float abstract = noise(vec2(uv.x*15.+mouse, uv.y+mouse));
  uv += abstract;

  uvg = zoom(uvg, n); // zoom tile uvg, a trick function but works;

  vec3 col = 1.0 - mix(vec3(1.), vec3(0.), vec3(noise(uv*8.0-vec2(u_time/2., u_time/2.0))));

  vec3 gradient_col = gradient(uv, vec3(0.93, 0., 1.), vec3(0.21, 0.61, 1.));

  col = mix(col, gradient_col, 0.5);

	vec3 halftone_col = halftone(uvg, 0.5, col);

  vec3 abstract_col = mix(vec3(0), vec3(1, 1, 1), 5.0*vec3(pow(1.0-noise(uv*4.0-vec2(u_time/2., u_time/2.0)),4.0)));
  abstract_col = mix(abstract_col, vec3(0.6863, 0.4902, 0.0275), 1.3); // make gradient color 
  abstract_col = pow(abstract_col, vec3(1./2.2))*b(1.0); // make color more bright

  vec3 final_col = mix(gradient_col, col, 0.5);
  final_col = mix(final_col, abstract_col, 0.5);
  final_col = mix(final_col, halftone_col, 0.1);

  gl_FragColor = vec4(final_col,1.0); // final color
}
