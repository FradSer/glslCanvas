// Frad LEE @ 2021 
// Enhanced version with improved color transitions

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

// Improved hash function for better randomness
float hash(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yxz + 19.19);
    return -1.0 + 2.0 * fract((p3.x + p3.y) * p3.z);
}

// Enhanced noise function
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    return mix(mix(hash(i + vec2(0.0,0.0)), 
                   hash(i + vec2(1.0,0.0)), u.x),
               mix(hash(i + vec2(0.0,1.0)), 
                   hash(i + vec2(1.0,1.0)), u.x), u.y);
}

// Improved FBM with more octaves for richer detail
float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    float lacunarity = 2.0;
    float gain = 0.5;
    
    for(int i = 0; i < 6; i++) {
        value += amplitude * noise(p * frequency);
        frequency *= lacunarity;
        amplitude *= gain;
    }
    return value * 1.2; // Amplify the effect
}

// Enhanced color palette system with multiple color schemes
vec3 palette(float t, float scheme) {
    // Base colors for scheme 1 - More vibrant colors
    vec3 a1 = vec3(0.8, 0.4, 0.5);
    vec3 b1 = vec3(0.4, 0.5, 0.6);
    vec3 c1 = vec3(2.0, 1.5, 1.0);
    vec3 d1 = vec3(0.00, 0.33, 0.67);
    
    // Base colors for scheme 2 - Complementary colors
    vec3 a2 = vec3(0.5, 0.7, 0.4);
    vec3 b2 = vec3(0.6, 0.4, 0.5);
    vec3 c2 = vec3(1.5, 1.0, 0.8);
    vec3 d2 = vec3(0.7, 0.33, 0.27);
    
    // Interpolate between schemes with enhanced mixing
    float mixFactor = scheme * scheme * (3.0 - 2.0 * scheme); // Smoother transition
    vec3 a = mix(a1, a2, mixFactor);
    vec3 b = mix(b1, b2, mixFactor);
    vec3 c = mix(c1, c2, mixFactor);
    vec3 d = mix(d1, d2, mixFactor);
    
    return a + b * cos(6.28318 * (c * t + d));
}

// Refined halftone effect with perfect circles and improved brightness mapping
vec3 halftone(vec2 st, float size, vec3 col) {
    // Adjust coordinates to maintain aspect ratio for perfect circles
    vec2 aspect = vec2(u_resolution.x/u_resolution.y, 1.0);
    vec2 st_adjusted = st * aspect;
    
    // Calculate center position for each circle
    vec2 center = fract(st_adjusted * size) - 0.5;
    center = center / aspect; // Correct the center position
    float dist = length(center);
    
    // Enhanced brightness calculation using perceived luminance
    float brightness = dot(col, vec3(0.299, 0.587, 0.114));
    
    // Improved radius calculation with more dramatic size variation
    float radius = 0.35 * pow(brightness, 1.2); // More dramatic size difference based on brightness
    
    // Sharper circle edges with anti-aliasing
    float pattern = smoothstep(radius, radius - 0.01, dist);
    
    // Enhanced contrast between dot and background
    return mix(col * 0.7, col * 1.3, pattern);
}

void main() {
    vec2 uv = gl_FragCoord.xy/u_resolution.xy;
    vec2 uvN = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / min(u_resolution.x, u_resolution.y);
    
    // Enhanced time variables for faster movement
    float t = u_time * 0.25; // Increased speed
    vec2 mouse = u_mouse.xy/u_resolution.xy;
    
    // Multiple flow fields with enhanced movement
    float flow1 = fbm(uvN * 2.5 + vec2(t * 0.4, t * 0.3));
    float flow2 = fbm(uvN * 3.5 - vec2(t * 0.3, t * 0.5));
    float flow3 = fbm(uvN * 1.5 + vec2(-t * 0.2, t * 0.4));
    
    // Complex flow combination
    float flow = mix(mix(flow1, flow2, 0.5), flow3, 0.3);
    
    // Dynamic color scheme blending with faster transitions
    float scheme = sin(t * 0.2) * 0.5 + 0.5;
    
    // Enhanced color composition with more dynamic movement
    vec3 col1 = palette(uv.x + flow + t * 0.3, scheme);
    vec3 col2 = palette(uv.y - flow + t * 0.35, 1.0 - scheme);
    vec3 col3 = palette(length(uvN) + flow * 0.7 + t * 0.4, scheme * 0.7);
    
    // More dynamic color blending
    float blend1 = sin(t * 1.2 + flow * 2.0) * 0.5 + 0.5;
    float blend2 = cos(t * 0.9 + flow * 3.0) * 0.5 + 0.5;
    
    // Enhanced color mixing
    vec3 finalColor = mix(col1, col2, blend1);
    finalColor = mix(finalColor, col3, blend2 * 0.7);
    
    // Amplified noise variation
    float noisePattern = fbm(uv * 12.0 + t * 0.7);
    finalColor = mix(finalColor, finalColor * (1.0 + noisePattern * 0.4), 0.35);
    
    // Keep original halftone effect with dynamic size
    float halftoneSize = 40.0 + sin(t) * 10.0;
    vec3 halftoneColor = halftone(uvN, halftoneSize, finalColor);
    finalColor = mix(finalColor, halftoneColor, 0.25);
    
    // Enhanced color grading
    finalColor = pow(finalColor, vec3(0.85)); // Increased contrast
    finalColor *= 1.15; // More brightness
    
    gl_FragColor = vec4(finalColor, 1.0);
}
