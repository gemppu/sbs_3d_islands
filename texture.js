let Texture = class{
  constructor(h, w, gl){
    this.h = h;
    this.w = w;
    this.gl = gl;

    this.fb = gl.createFramebuffer();
    gl.bindFramebuffer(gl.FRAMEBUFFER, this.fb);

    this.tex = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, this.tex);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, w, h, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.MIRRORED_REPEAT);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.MIRRORED_REPEAT);
    gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, this.tex, 0);
    this.rb = gl.createRenderbuffer();
    gl.bindRenderbuffer(gl.RENDERBUFFER, this.rb);
    gl.renderbufferStorage(gl.RENDERBUFFER, gl.DEPTH_COMPONENT16, w, h);
    gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_ATTACHMENT, gl.RENDERBUFFER, this.rb);
    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
  }
  get textureID(){
    return this.tex;
  }
  get resolution(){
    return this.h, this.w;
  }
  render(){
    var prevViewport = this.gl.getParameter(this.gl.VIEWPORT);
    this.gl.bindFramebuffer(this.gl.FRAMEBUFFER, this.fb);
    this.gl.clear(this.gl.COLOR_BUFFER_BIT);
    this.gl.viewport(0, 0, this.w, this.h);
    this.gl.drawArrays(this.gl.TRIANGLE_STRIP, 0, 4);
    this.gl.bindFramebuffer(this.gl.FRAMEBUFFER, null);
    this.gl.viewport(prevViewport[0], prevViewport[1], prevViewport[2], prevViewport[3]);
  }
}

    



