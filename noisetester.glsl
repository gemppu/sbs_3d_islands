precision mediump float;
uniform vec2 u_resolution;
uniform sampler2D texture1;
void main(){
  //vec2 uv = (gl_FragCoord.xy/vec2(500,500))*2.0-vec2(.5,1.);
  vec2 uv = (gl_FragCoord.xy/u_resolution)*2.0-vec2(.5,1.);
  vec4 texCol = texture2D(texture1, gl_FragCoord.xy);
  if( gl_FragCoord.x > u_resolution.x/2.){
    gl_FragColor = vec4(uv,0., 1.); 
  }else{
    gl_FragColor = texCol;
  }

}
