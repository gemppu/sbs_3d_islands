precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;
uniform sampler2D texture1;
uniform vec2 u_tex_resolution;

#define MAXDIST 256.
#define MINSTEP .1
#define MAXSTEPS 400 
#define HITRATIO .01
#define STEPRATIO .5
#define STEPLEN .05
#define EPSILON .0001
#define VIEWDISTANCE 196.
#define SHARDNESS 32.
#define EYEWIDTH .1
#define TEXTURESCALE 50.

//COLOR PALLETTE
#define COL_BG vec4(1.00, 0.16, 0.46, 1.0)
#define COL_CLOUD vec4(0.55, 0.12, 1.00, 1.0)
#define COL_FLOOR vec4(0.95, 0.13, 1.00, 1.0)
#define COL_ORANGE vec4(1.00, 0.56, 0.12, 1.0)
#define COL_YELLOW vec4(1.00, 0.83, 0.10, 1.0)

float hash(vec3 p)  // replace this by something better
{
    p  = fract( p*0.3183099+.1 );
	p *= 17.0;
    return fract( p.x*p.y*p.z*(p.x+p.y+p.z) );
}

float noise( in vec3 x )
{
    vec3 i = floor(x);
    vec3 f = fract(x);
    f = f*f*(3.0-2.0*f);
	
    return mix(mix(mix( hash(i+vec3(0,0,0)), 
                        hash(i+vec3(1,0,0)),f.x),
                   mix( hash(i+vec3(0,1,0)), 
                        hash(i+vec3(1,1,0)),f.x),f.y),
               mix(mix( hash(i+vec3(0,0,1)), 
                        hash(i+vec3(1,0,1)),f.x),
                   mix( hash(i+vec3(0,1,1)), 
                        hash(i+vec3(1,1,1)),f.x),f.y),f.z);
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

float sphereSDF(vec3 rayPos, float r, vec3 spherePos){
  return distance(rayPos,spherePos)-r;
}


float cloudSDF(vec3 p, out float h){
  float scale = 50.;
  vec2 uv = (p.xz+vec2(scale,u_time*.5))/scale;
  float displace = length(texture2D(texture1, uv));
  float displace_big = length(texture2D(texture1, uv/4.));
  h = displace*2. + displace_big*4.;
  return -p.y +15. + 2. * h;
}

float terrainSDF(vec3 p){
  //float h = length(texture2D(texture1, p.xz/TEXTURESCALE).xz);
  //float h = noise(vec3(p.xz/10.,0.));
  float y = 1. + 10.*noise(vec3(p.xz/5.,0.));
  return p.y - y;
  return p.y;
}
  
float cubefieldSFD(vec3 p){
  
  float w = 1.;
  vec3 wp = vec3(mod(p.x, w), p.y, mod(p.z, w));
  float y = 5.*noise(vec3(floor(p.xz)/5.,u_time*.01));
  //float y = 10.*noise(vec3(p.xz/5.,0.));
  vec3 dims = vec3(.8*w,y+.5,.8*w);
  float dist = sdRoundBox(wp, dims, .01);
  
  return dist;
}
  

float distToClosest(in vec3 p, out vec3 c){
  c = vec3(0);
  float dist = MAXDIST;
  #if 1
  float cubeFieldDist = cubefieldSFD(p);
  if(cubeFieldDist< dist){
    dist = cubeFieldDist;
    vec3 topCol = vec3(0.82, 0.37, 0.78);
    vec3 botCol = vec3(0.76, 0.38, 0.04);
    botCol = COL_YELLOW.rgb;
    topCol = COL_ORANGE.rgb;
    c = mix(topCol, botCol, 1.-p.y*.5);
    //c = vec3(mod(u_time,1.)*(20.)-10.-p.y);
    //c = vec3(5.-p.y)/2.;
  }
  #endif
  #if 0 
  float terrainDist = terrainSDF(p);
  if(terrainDist< dist){
    dist = terrainDist;
    c = vec3(5., 0., 0.);
  }
  #endif
  #if 1
  float cloudHeight;
  float cloudDist = cloudSDF(p, cloudHeight);
  if(cloudDist < dist){
    dist = cloudDist;
    vec4 cloudCol = mix(vec4(0.93, 0.82, 0.68, 1.0), vec4(0.68, 0.93, 0.93, 1.0), texture2D(texture1, p.xz*.1).x);
    //cloudCol = mix(vec4(.2), vec4(vec3(0.),1.), (p.z-sin(u_time)*15.)*.1);
    //cloudCol = mix(vec4(.2), vec4(vec3(0.),1.), mod(cloudHeight,1.));
    cloudCol = COL_CLOUD * (cloudHeight*.1-.5);
    c = cloudCol.xyz;
  }
  #endif
  if(p.y<0.){
    dist = p.y;
    c = vec3(2.);
  }

  return dist;
}


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
  float distTravelled = 0.;
  col = vec3(0.);
  normal = vec3(0.);
  for(int steps = 0; steps<MAXSTEPS; steps++){
    float dist = distToClosest(pos, col);
    pos += STEPLEN*rd;
    distTravelled += STEPLEN;
    if(dist < HITRATIO * distance(o,pos)){
      normal = getNormal(pos);
      return true;
    }
    if(distTravelled > MAXDIST || steps+1 == MAXSTEPS){
      return false;
    }
  }
  return false;
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
  vec3 col = COL_BG.rgb;
  vec3 n = vec3(0.);
  vec3 p = o;
  bool hit = intersect(o,rd, p ,n,col);
  vec3 lamp_pos = vec3(0., 3., 5.*sin(u_time)-10.);
  if(hit){
    //col = phong(p, o, rd, col,n, lamp_pos,100.);
  }
  float distance_normalized = clamp(length(o-p)/ VIEWDISTANCE, 0., 1.);
  vec3 bgCol = COL_BG.rgb;
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
  
  vec2 uv = (gl_FragCoord.xy/u_resolution)*2.0-1.;
  float aspect = u_resolution.x/u_resolution.y;
  vec3 timeOffset = vec3(u_time,0.,-2. * u_time);
  vec3 o =  timeOffset + vec3(5.,11.,8.);
  vec3 t =  timeOffset + vec3(5.,1.,1.);
  
  vec3 rd = ray_dir(uv, o, t);
  col = shoot(o,rd);
  return col;
}

void main(){
  gl_FragColor = gamma_correction(raymarching(), .5);
}
