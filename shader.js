Class shader{
  constructor(gl, fsSource, vsSource){

    this.fs = gl.createShader(gl.FRAGMENT_SHADER);
    gl.shaderSource(fs, fsSource);
    gl.compileShader(fs)
    if ( !gl.getShaderParameter(fs, gl.COMPILE_STATUS) ) {
      var info = gl.getShaderInfoLog( fs );
      throw 'Could not compile WebGL program. \n\n' + info;
    }

    this.vs = gl.createShader(gl.VERTEX_SHADER);
    gl.shaderSource(vs, vsSource);
    gl.compileShader(vs);
    if ( !gl.getShaderParameter(vs, gl.COMPILE_STATUS) ) {
      var info = gl.getShaderInfoLog( vs );
      throw 'Could not compile WebGL program. \n\n' + info;
    }

    this.program = gl.createProgram();
    gl.attachShader(this.program, vs);
    gl.attachShader(this.program, fs);
    gl.linkProgram(program);
    if ( !gl.getProgramParameter( program, gl.LINK_STATUS) ) {
      var info = gl.getProgramInfoLog(program);
      throw 'Could not compile WebGL program. \n\n' + info;
    }
  }
  use(){
    gl.useProgram(this.program);
  }
  setUniform1f(name, x){
    gl.uniform1f(gl.getUniformLocation(this.program, name, x);
  }
  setUniform1i(name, x){
    gl.uniform1i(gl.getUniformLocation(this.program, name, x);
  }
  setUniform2f(name, a, b){
    gl.uniform2f(gl.getUniformLocation(this.program, name, a, b);
  }
  setUniform2i(name, a, b){
    gl.uniform2i(gl.getUniformLocation(this.program, name, a, b);
  }

