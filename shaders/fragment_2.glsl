// Frad LEE @ 2021 
// Base on https://codepen.io/DonKarlssonSan/pen/gROawd

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;


// From Stackoveflow
// http://stackoverflow.com/questions/15095909/from-rgb-to-hsv-in-opengl-glsl
  vec3 hsv2rgb(vec3 c)
  {
      vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
      vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
      return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
  }

// Simplex 2D noise
// from https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
vec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }

float snoise(vec2 v){
    const vec4 C = vec4(0.211324865405187, 0.366025403784439,
                        -0.577350269189626, 0.024390243902439);
    vec2 i  = floor(v + dot(v, C.yy) );
    vec2 x0 = v -   i + dot(i, C.xx);
    vec2 i1;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod(i, 289.0);
    vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
                      + i.x + vec3(0.0, i1.x, 1.0 ));
    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy),
                            dot(x12.zw,x12.zw)), 0.0);
    m = m*m ;
    m = m*m ;
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
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

void main(){
  vec2 uv = gl_FragCoord.xy/u_resolution.xy; 

  float mouse = u_mouse.x/u_resolution.x*u_mouse.y/u_resolution.y; // mouse

  float xnoise = snoise(vec2(uv.x, 0.));
  float ynoise = snoise(vec2(uv.y, 0.));
  vec2 t = vec2(xnoise + mouse, ynoise + mouse);
  float s1 = snoise(uv + t / 2.0 + snoise(uv + snoise(uv + t/3.0) / 5.0));
  float s2 = snoise(uv + snoise(uv + s1) / 7.0);
  vec3 hsv = vec3(s1, 1.0, 1.0-s2);
  vec3 final_col = hsv2rgb(hsv); // final color

	vec3 halftone_col = halftone(uv, 0.01, final_col);

  final_col = mix(final_col, halftone_col, 0.2);

  gl_FragColor = vec4(final_col,1.0);
}
