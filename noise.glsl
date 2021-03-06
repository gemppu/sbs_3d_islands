precision mediump float;

uniform float u_time;
uniform vec2 u_resolution; 

//
#define PI 3.14159265359
#define EPSILON 0.00001


//  https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
//	Simplex 3D Noise
//	by Ian McEwan, Ashima Arts
//
vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}

float snoise(vec3 v){
    const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
    const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

    // First corner
    vec3 i  = floor(v + dot(v, C.yyy) );
    vec3 x0 =   v - i + dot(i, C.xxx) ;

    // Other corners
    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min( g.xyz, l.zxy );
    vec3 i2 = max( g.xyz, l.zxy );

    //  x0 = x0 - 0. + 0.0 * C
    vec3 x1 = x0 - i1 + 1.0 * C.xxx;
    vec3 x2 = x0 - i2 + 2.0 * C.xxx;
    vec3 x3 = x0 - 1. + 3.0 * C.xxx;

    // Permutations
    i = mod(i, 289.0 );
    vec4 p = permute( permute( permute(
    i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
    + i.y + vec4(0.0, i1.y, i2.y, 1.0 ))
    + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

    // Gradients
    // ( N*N points uniformly over a square, mapped onto an octahedron.)
    float n_ = 1.0/7.0; // N=7
    vec3  ns = n_ * D.wyz - D.xzx;

    vec4 j = p - 49.0 * floor(p * ns.z *ns.z);  //  mod(p,N*N)

    vec4 x_ = floor(j * ns.z);
    vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

    vec4 x = x_ *ns.x + ns.yyyy;
    vec4 y = y_ *ns.x + ns.yyyy;
    vec4 h = 1.0 - abs(x) - abs(y);

    vec4 b0 = vec4( x.xy, y.xy );
    vec4 b1 = vec4( x.zw, y.zw );

    vec4 s0 = floor(b0)*2.0 + 1.0;
    vec4 s1 = floor(b1)*2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));

    vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
    vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

    vec3 p0 = vec3(a0.xy,h.x);
    vec3 p1 = vec3(a0.zw,h.y);
    vec3 p2 = vec3(a1.xy,h.z);
    vec3 p3 = vec3(a1.zw,h.w);

    //Normalise gradients
    vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;

    // Mix final noise value
    vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
    m = m * m;
    return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1),
    dot(p2,x2), dot(p3,x3) ) );
}

float safe_snoise(vec3 p)
{
    float f = snoise(p);
    if (f>999999999.)
    return 0.0;
    return f;
}

// https://github.com/blender/blender/blob/master/intern/cycles/kernel/shaders/node_noise.h

float fractal_noise(vec3 p, float details, float roughness)
{
    float fscale = 1.0;
    float amp = 1.0;
    float maxamp = 0.0;
    float sum = 0.0;
    float octaves = clamp(details, 0.0, 16.0);
    int n = int(octaves);
    for (int i = 0; i <= 999; i++) {
        if(i>=n) break;
        float t = safe_snoise(fscale * p);
        sum += t * amp;
        maxamp += amp;
        amp *= clamp(roughness, 0.0, 1.0);
        fscale *= 2.0;
    }
    float rmd = octaves - floor(octaves);
    if (rmd != 0.0) {
        float t = safe_snoise(fscale * p);
        float sum2 = sum + t * amp;
        sum /= maxamp;
        sum2 /= maxamp + amp;
        return (1.0 - rmd) * sum + rmd * sum2;
    }
    else {
        return sum / maxamp;
    }
}

// https://github.com/blender/blender/blob/master/intern/cycles/kernel/shaders/node_noise_texture.osl
vec3 random_vec3_offset(float seed)
{
    return vec3(100.0 + snoise(vec3(seed)) * 100.0,
    100.0 + snoise(vec3(seed)) * 100.0,
    100.0 + snoise(vec3(seed)) * 100.0);
}

vec3 noiseTexture(vec3 pos, float detail, float roughness){
    vec3 p = pos;
    float value = fractal_noise(p, detail, roughness);

    return (vec3(value,
    fractal_noise(p+random_vec3_offset(0.), detail, roughness),
    fractal_noise(p+random_vec3_offset(1.), detail, roughness)));
}

vec3 noiseTextureChain(vec3 p){
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = gl_FragCoord.xy/u_resolution.xy;
    uv *= 2.;
    float detail1 = 8.;
    float detail2 = 1.;
    float roughness1 = .5;
    float roughness2 = .5;
    vec3 pIn1 = vec3(p);
    vec3 pIn2 = noiseTexture(pIn1,detail1,roughness1);
    vec3 col = noiseTexture(pIn2,detail2,roughness2);
    // contrast
    col *= .7;
    // brightness
    col += .5;
    return col;
}

float hash1( float n )
{
    return fract( n*17.0*fract( n*0.3183099 ) );
}

float noise(vec3 x){
    vec3 p = floor(x);
    vec3 w = fract(x);
    vec3 u = w*w*(3.0-2.0*w);

    float n = p.x + 317.0*p.y + 157.0*p.z;
    
    float a = hash1(n+0.0);
    float b = hash1(n+1.0);
    float c = hash1(n+317.0);
    float d = hash1(n+318.0);
    float e = hash1(n+157.0);
	float f = hash1(n+158.0);
    float g = hash1(n+474.0);
    float h = hash1(n+475.0);

    float k0 =   a;
    float k1 =   b - a;
    float k2 =   c - a;
    float k3 =   e - a;
    float k4 =   a - b - c + d;
    float k5 =   a - c - e + g;
    float k6 =   a - b - e + f;
    float k7 = - a + b + c - d + e - f - g + h;

    return -1.0+2.0*(k0 + k1*u.x + k2*u.y + k3*u.z + k4*u.x*u.y + k5*u.y*u.z + k6*u.z*u.x + k7*u.x*u.y*u.z);
}

float fbm(vec3 x, float H){
    float G = exp2(-H);
    float t = .0;
    float f = 1.;
    float a = 1.;
    for( int i = 0; i<6; i++){
        t += a * noise(f * x);
        f *= 2.;
        a *= G;
    }
    return t;
}

void main()
{
    vec2 uv = gl_FragCoord.xy/u_resolution.xy;
    uv *= 1.;
    float time = u_time/10.;
    vec3 p = vec3(uv.x, uv.y+time*.01, time*0.4);
    float detail1 = 8.;
    float detail2 = 1.;
    float roughness1 = .5;
    float roughness2 = .2;
    float f1 = fractal_noise(p,detail1,roughness1);
    vec3 pIn1 = p;
    vec3 pIn2 = noiseTexture(pIn1,detail1,roughness1);
    vec3 pIn3 = noiseTexture(pIn2,detail2,roughness2);
    vec3 col = noiseTexture(pIn3,detail2,roughness2);
    // contrast
    col *= .7;
    // brightness
    col += .5;
    gl_FragColor = vec4(col,1.);
    return;
    //col = vec3(snoise(p));
    gl_FragColor = vec4(vec3((f1+1.)*.5),1.);
    
}
