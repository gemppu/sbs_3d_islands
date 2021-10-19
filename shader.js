let Shader = class{
  constructor(gl, fsSource, vsSource){

    this.gl = gl
    this.fs = gl.createShader(gl.FRAGMENT_SHADER);
    gl.shaderSource(this.fs, fsSource);
    gl.compileShader(this.fs)
    if ( !gl.getShaderParameter(this.fs, gl.COMPILE_STATUS) ) {
      var info = gl.getShaderInfoLog( this.fs );
      throw 'Could not compile WebGL program. \n\n' + info;
    }

    this.vs = gl.createShader(gl.VERTEX_SHADER);
    gl.shaderSource(this.vs, vsSource);
    gl.compileShader(this.vs);
    if ( !gl.getShaderParameter(this.vs, gl.COMPILE_STATUS) ) {
      var info = gl.getShaderInfoLog( this.vs );
      throw 'Could not compile WebGL program. \n\n' + info;
    }

    this.program = gl.createProgram();
    gl.attachShader(this.program, this.vs);
    gl.attachShader(this.program, this.fs);
    gl.linkProgram(this.program);
    if ( !gl.getProgramParameter( this.program, gl.LINK_STATUS) ) {
      var info = gl.getProgramInfoLog(this.program);
      throw 'Could not compile WebGL program. \n\n' + info;
    }
  }
  use(){
    this.gl.useProgram(this.program);
  }
  
  setUniform1f(name, x){
    this.gl.uniform1f(this.gl.getUniformLocation(this.program, name), x);
  }
  
  setUniform1i(name, x){
    this.gl.uniform1i(this.gl.getUniformLocation(this.program, name), x);
  }
  
  setUniform2f(name, a, b){
    this.gl.uniform2f(this.gl.getUniformLocation(this.program, name), a, b);
  }
  
  setUniform2i(name, a, b){
    this.gl.uniform2i(this.gl.getUniformLocation(this.program, name), a, b);
  }
  getAttribLocation(name){
    return this.gl.getUniformLocation(this.program, name);
  }
}


