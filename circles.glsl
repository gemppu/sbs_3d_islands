precision mediump float;
uniform vec2 u_resolution;


vec4 circles(vec2 uv){
  uv *= 2.;
  vec4 col = vec4(vec3(1.),1.);
  uv = mod(uv,1.)-vec2(.5);
  //return vec4(vec3(length(uv)), 1.);
  //return vec4(uv, 0., 1.);
  return vec4(vec3(clamp(100.*(1.-length(uv)-.6),0.,1.)),1.);
  if(length(uv)<.4) return col;
  return vec4(vec3(0.),1.);
}


float planeIntersect(vec3 ro, vec3 rd, vec4 p){
  return -(dot(ro,p.xyz)+p.w)/dot(rd,p.xyz);
}


vec3 ray_dir(vec2 uv, vec3 origin, vec3 target){
  vec3 forward = normalize(target-origin);
  vec3 right = normalize(cross(vec3(0.,1.,0.),forward));
  vec3 up = normalize(cross(forward, right));

  float near = 1.;
  vec3 ray_direction = normalize(uv.x*right+uv.y*up+forward*near);
  return ray_direction;
}


void main(){
  //vec2 uv = (gl_FragCoord.xy/vec2(500,500))*2.0-vec2(.5,1.);
  vec2 uv = (gl_FragCoord.xy/u_resolution)*2.0-vec2(.5,1.);
  float aspect = u_resolution.x/u_resolution.y;
  vec3 ro = vec3(0.);
  vec3 rt = vec3(0.,0.,1.);
  vec3 rd = ray_dir(uv, ro, rt);
  
  uv.x *= aspect;
  float uvy = uv.y + 1.;
  uv.y = 1./uvy;
  uv.x = 1./uv.x;
  gl_FragColor = circles(uv);
  //gl_FragColor = vec4(uv, 0., 1.); 
}
