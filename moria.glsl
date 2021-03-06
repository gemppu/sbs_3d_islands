precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;
uniform sampler2D texture1;
uniform vec2 u_tex_resolution;

#define MAXDIST 100.
#define MINSTEP .001
#define MAXSTEPS 100
#define HITRATIO .001
#define EPSILON .0001
#define VIEWDISTANCE 50.
#define SHARDNESS 32.
#define EYEWIDTH .1
#define TEXTURESCALE 50.

vec4 interpolate_texture(sampler2D smp, vec2 uv){
  //vec2 res = textureSize(smp);
  vec2 res = u_tex_resolution;
  vec2 st = uv*res -.5;
  vec2 iuv = floor(st);
  vec2 fuv = fract(st);
  vec4 a = texture2D(smp, (iuv+vec2(.5,.5)/res));
  vec4 b = texture2D(smp, (iuv+vec2(1.5,.5)/res));
  vec4 c = texture2D(smp, (iuv+vec2(.5,1.5)/res));
  vec4 d = texture2D(smp, (iuv+vec2(1.5,1.5)/res));
  return mix(mix(a,b,fuv.x),mix(c,d,fuv.x),fuv.y);
}
  
float floorSDF(vec3 p, float h){
  return abs(p.y-h);
}

float sdRoundBox(vec3 p, vec3 b, float r){
  vec3 q = abs(p)-b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0)-r;
}


float sdCylinder(vec3 p, vec3 c){
  return length(p.xz-c.xy)-c.z;
}

float holviSDF(vec3 p){
  p.x = mod(p.x+2.,4.)-2.;
  p.z = mod(p.z+2.,4.)-2.;
  float h = 4.;
  float r = 1.8;
  float boxDist = sdRoundBox(p,vec3(2.,h+r+.1,2.),0.);
  float cylxDist = length(p.xy -vec2(.0,h))-r;
  float cylzDist = length(p.zy-vec2(.0,h))-r;
  float cylDist = min(cylxDist, cylzDist);
  float boxxDist = sdRoundBox(p, vec3(2.5,h,r),0.);
  float boxzDist = sdRoundBox(p, vec3(r,h,2.5),0.);
  float box1Dist = min(boxxDist, boxzDist);
  float cutDist = min(box1Dist, cylDist);
  float dist = max(boxDist, -cutDist);
  return dist;
}
float sphereSDF(vec3 rayPos, float r, vec3 spherePos){
  return distance(rayPos,spherePos)-r;
}

float terrainSDF(vec3 p){
  float h = length(interpolate_texture(texture1, p.xz*.1).xz);
  //return p.y-h*2.;
  return p.y;
}
  

float distToClosest(in vec3 p, out vec3 c){
  c = vec3(0);
  float dist = MAXDIST;
  float terrainDist = terrainSDF(p);
  if(terrainDist < dist){
    dist = terrainDist;
    //c = vec3(.5);
    c = texture2D(texture1, p.xz*.1).xyz;
    c = interpolate_texture(texture1, p.xz*.001).xyz;

  }
  return dist;
}

#if 0
float distToClosest(in vec3 pos, out vec3 col){
  col = vec3(0.);
  float dist = MAXDIST;
  vec3 sphereLoc = vec3(0., 3., 5.*sin(u_time)-11.);
  float sphereDist = sphereSDF(pos,.5,sphereLoc);
  if(sphereDist < dist){
    dist = sphereDist;
    col = vec3(1.,0.,0.);
  }
  float floorDist = floorSDF(pos,0.);
  if(floorDist < dist){
    dist = floorDist;
    col = vec3(.2);
  }
  float holviDist = holviSDF(pos);
  if(holviDist < dist){
    dist = holviDist;
    col = vec3(.6);
    col = mix(vec3(.2),vec3(.6),pos.y);
  }

  return dist;

}
#endif

vec3 getNormal(vec3 position){
  const vec2 k = vec2(1.0, -1.0);
  vec3 col = vec3(0.);
  return normalize(
      k.xyy * distToClosest(position + k.xyy * EPSILON, col) +
      k.yyx * distToClosest(position + k.yyx * EPSILON, col) +
      k.yxy * distToClosest(position + k.yxy * EPSILON, col) +
      k.xxx * distToClosest(position + k.xxx * EPSILON, col)
      );
}

bool intersect(in vec3 o, in vec3 rd, out vec3 pos, out vec3 normal, out vec3 col){
  pos = o;
  float stpLen = 0.;
  float distTravelled = 0.;
  col = vec3(0.);
  normal = vec3(0.);
  for(int steps = 0; steps<MAXSTEPS; steps++){
    stpLen = distToClosest(pos, col);
    if(stpLen<MINSTEP) stpLen=MINSTEP;
    pos += stpLen*rd;
    distTravelled += stpLen;
    if(abs(stpLen) < HITRATIO * distance(o,pos)){
      normal = getNormal(pos);
      return true;
    }
    if(distTravelled > MAXDIST || steps+1 == MAXSTEPS){
      col = vec3(0.);
      return false;
    }
  }
  return false;
}

float shadow(vec3 o, vec3 lamp_pos){
  float res = 1.0;
  float ph = 1e20;
  vec3 p = o;
  vec3 ld = normalize(lamp_pos-p); // light direction
  float dt = 0.; // distance travelled
  float sl = 0.; // step length
  float c = MAXDIST; //closest dist
  vec3 col = vec3(0.);
  for(int steps=0; steps<MAXSTEPS; steps++){
    sl = distToClosest(p,col);
    if(sl<MINSTEP && steps == 0) sl=MINSTEP;
    if(sl<HITRATIO) return 0.1;
    float y = sl*sl/(2.0*ph);
    float d = sqrt(sl*sl-y*y);
    res = min(res, SHARDNESS*d/max(0.0, dt-y));
    p += ld*sl;
    dt += sl;
  }
  return res;
}

vec3 phong(vec3 p, vec3 o, vec3 rd, vec3 col, vec3 n, vec3 lamp_pos, float lamp_str){
  vec3 ld = normalize(lamp_pos-p);
  vec3 amb = .1*col;
  vec3 diff = max(dot(n,ld),0.)*col;
  vec3 spec = pow(max(dot(rd, reflect(ld,n)),0.),32.)*col;
  float dm = lamp_str/pow((length(o-p)+length(p-lamp_pos)),2.);//distance multiplier
  float s = 1.;//shadow(p,lamp_pos);
  vec3 sum = s*dm*(amb+diff+spec);
  return sum;
}

vec4 shoot(in vec3 o, in vec3 rd){
  vec3 col = vec3(0.);
  vec3 n = vec3(0.);
  vec3 p = o;
  bool hit = intersect(o,rd, p ,n,col);
  vec3 lamp_pos = vec3(0., 3., 5.*sin(u_time)-10.);
  if(hit){
    col = phong(p, o, rd, col,n, lamp_pos,100.);
  }
  float distance_normalized = clamp(length(o-p)/ VIEWDISTANCE, 0., 1.);
  vec3 bgCol = vec3(0.1);
  col = mix(col, bgCol, distance_normalized);
  return vec4(col,1.);

}
vec3 ray_dir(vec2 uv, vec3 origin, vec3 target){
  vec3 forward = normalize(target-origin);
  vec3 right = normalize(cross(vec3(0.,1.,0.),forward));
  vec3 up = normalize(cross(forward, right));

  float near = 1.;
  vec3 ray_direction = normalize(uv.x*right+uv.y*up+forward*near);
  return ray_direction;
}
vec4 gamma_correction(vec4 col, float gamma){
  col.x = pow(col.x,gamma);
  col.y = pow(col.y,gamma);
  col.z = pow(col.z,gamma);
  return col;
}
vec4 raymarching(){
  vec4 col = vec4(.0);
  
  if(gl_FragCoord.x<u_resolution.x/2.){
    //vec2 uv = (gl_FragCoord.xy/u_resolution)*2.0-1.0;
    vec2 uv = (gl_FragCoord.xy/u_resolution)*2.0-vec2(.5,1.);
    float aspect = (u_resolution.x)/u_resolution.y;
    uv.x = uv.x*aspect/2.;
    //vec3 o = vec3(sin(u_time), 4.,8.);
    vec3 o = vec3(0.,4.,8.);
    //vec3 t = vec3(0.);
    vec3 t = vec3(0.,0.,-20.);
    o += vec3(1.,0.,0.);
    t += vec3(1.,0.,0.);
    vec3 rd = ray_dir(uv, o, t);
    col = shoot(o,rd);
    //col = vec4(uv,0.,1.);
  }else{
    vec2 modCoord = vec2(mod(gl_FragCoord.x,u_resolution.x/2.),gl_FragCoord.y);
    vec2 uv = (modCoord/u_resolution)*2.0-vec2(.5,1.);
    float aspect = u_resolution.x/u_resolution.y;
    uv.x = uv.x*aspect/2.;
    //vec3 o = vec3(sin(u_time), 4.,8.);
    vec3 o = vec3(.1,4.,8.);
    vec3 t = vec3(0.,0.,-20.);
    o += vec3(1.,0.,0.);
    t += vec3(1.,0.,0.);
    vec3 rd = ray_dir(uv, o, t);
    col = shoot(o,rd);
    //col = vec4(uv,0.,1.);
  }
  return col;
}
void main(){
  gl_FragColor = gamma_correction(raymarching(), .5);
}
