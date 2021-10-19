let Texture = class{
  constructor(h, w, gl){
    this.h = h;
    this.w = w;
    this.gl = gl;

    this.fb = gl.createFramebuffer();
    gl.bindFramebuffer(gl.FRAMEBUFFER, this.fb);

    this.tex = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, this.tex);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, w, h, 0, gl.RGBA, gl.UNSIGNED_BYTE, NULL);
    gl.texParametri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.texParametri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, GL_LINEAR);
    gl.texParametri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
    gl.texParametri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);
    gl.framebufferTexture2D(gl.FRAMEBUFFER, gl_COLOR_ATTACHMENT0, gl_TEXTURE_2D, this.tex, 0);
    this.rb = gl.createRenderbuffer();
    gl.bindRenderbuffer(gl.RENDERBUFFER, this.rb);
    gl.renderbufferStorage(gl.RENDERBUFFER, gl.DEPTH_COMPONENT16, w, h);
    gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_ATTACHMENT, gl.RENDERBUFFER, this.rb);
    gl.bindRenderbuffer(gl.RENDERBUFFER, 0);
  }
  get textureID(){
    return this.tex;
  }
  render(){
    prevViewport = gl.getParameter(gl.VIEWPORT);
    gl.bindFramebuffer(gl.FRAMEBUFFER, this.fb);
    gl.Clear(gl.COLOR_BUFFER_BIT);
    gl.viewport(0, 0, this.w, this.h);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
    gl.bindFramebuffer(GL_FRAMEBUFFER, 0);
    gl.viewport(prevViewport[0], prevViewport[1], prevViewport[2], prevViewport[3]);
  }
}

    



