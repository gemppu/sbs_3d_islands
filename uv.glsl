precision mediump float;
uniform vec2 u_resolution;
void main(){
  //vec2 uv = (gl_FragCoord.xy/vec2(500,500))*2.0-vec2(.5,1.);
  vec2 uv = (gl_FragCoord.xy/u_resolution)*2.0-vec2(.5,1.);
  gl_FragColor = vec4(uv, 0., 1.); 
}
