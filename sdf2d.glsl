precision mediump float;
uniform vec2 u_resolution;
uniform float u_time;

#if 0
float crossSDF(vec2 p, float r, float th){
  vec2 a = p + vec2(r,0.);
  vec2 b = p + vec2(-r,0.);
  vec2 a1 = p + vec2(0.,r);
  vec2 b1 = p + vec2(0.,-r);
  float l = 2.*r;
  vec2 d = (b-a)/l;
  vec2 q = (p-(a+b)*.5);
  q = mat2(d.x,-d.y,d.y,d.x)*q;
  q = abs(q)-vec2(l,th)*.5;
  return length(max(q,.0)) + min(max(q.x,q.y),.0);
}  
#endif

vec2 rotate(vec2 v, float a) {
	float s = sin(a);
	float c = cos(a);
	mat2 m = mat2(c, -s, s, c);
	return m * v;
}

float crossSDF(vec2 p, float r, float th){
  vec2 a = abs(p)-vec2(th,r*2.);
  vec2 b = abs(p)-vec2(r*2.,th);
  float ad = length(max(a,0.0)) + min(max(a.x,a.y),0.0);
  float bd = length(max(b,0.0)) + min(max(b.x,b.y),0.0);
  
  float ab = min(ad,bd);
  return ab;
  return (sin(u_time*2.)<0.)?ad:ab;
}

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

float crossGrid(in vec2 uv){
  float stime = sin((.5+u_time)*4.);
  float len = .2 + .05*stime;
  float th = .2 + .05*stime;
  float tr = crossSDF(rotate(uv+vec2(-1.),u_time), len, th);
  float tl = crossSDF(rotate(uv+vec2(-1.,0.),u_time), len, th);
  float c = 9.;//crossSDF(rotate(uv+vec2(-.5),u_time), .1+.05*stime,.1);
  float br = crossSDF(rotate(uv+vec2(.0),u_time), len, th);
  float bl = crossSDF(rotate(uv+vec2(.0,-1.),u_time), len, th);
  float dist = min(tr,min(tl,min(c,min(br,bl))));
  return dist;
}

float crossGrid1(in vec2 uv){
  float stime = 1.+sin((.5+u_time)*4.);
  //stime = 1.;
  float c = 9.;//crossSDF(rotate(uv+vec2(-.5,-.5),u_time), .1+.05*stime,.1);
  float t = crossSDF(rotate(uv+vec2(-.5,-1.),u_time), .1+.05*stime,.1);
  float l = crossSDF(rotate(uv+vec2(.0,-.5),u_time), .1+.05*stime,.1);
  float r = crossSDF(rotate(uv+vec2(-1.,-.5),u_time), .1+.05*stime,.1);
  float b = crossSDF(rotate(uv+vec2(-.5,.0),u_time), .1+.05*stime,.1);
  float dist = min(c,min(t,min(l,min(r,b))));
  return dist;
}

void main(){
  //vec2 uv = (gl_FragCoord.xy/vec2(500,500))*2.0-vec2(.5,1.);
  vec2 uv = (gl_FragCoord.xy/u_resolution)*2.0-vec2(.5,1.);
  float aspect = u_resolution.x/u_resolution.y;
  uv.x *= aspect;
  uv = mod(uv, 1.);
  float stime = sin((.5+u_time)*4.);
  //vec4 col = vec4(vec3(mod(crossSDF(rotate(uv+vec2(.0),u_time),.1+.05*stime,.1),.1)),1.);
  vec4 col = vec4(vec3(clamp(10.*crossGrid(uv),0.,1.)),1.);
  //vec4 col = vec4(vec3(sdBox(uv,vec2(.5))),1.);
  //gl_FragColor = vec4(uv, 0., 1.); 
  gl_FragColor = col;
}
