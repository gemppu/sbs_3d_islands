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


void main(){
  //vec2 uv = (gl_FragCoord.xy/vec2(500,500))*2.0-vec2(.5,1.);
  vec2 uv = (gl_FragCoord.xy/u_resolution)*2.0-vec2(.5,1.);
  gl_FragColor = circles(uv);
  //gl_FragColor = vec4(uv, 0., 1.); 
}
