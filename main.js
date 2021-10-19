
window.onload = function init() {
  const canvas = document.querySelector("#glCanvas");
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight
  // Initialize the GL context
  const gl = canvas.getContext("webgl");

  // Only continue if WebGL is available and working
  if (gl === null) {
    alert("Unable to initialize WebGL. Your browser or machine may not support it.");
    return;
  }

  var vertexShaderSource =
  'attribute vec4 position;\n' +
  'void main() {\n' +
  '  gl_Position = position;\n' +
  '}\n';

  var fragmentShaderSource = document.getElementById('fragment').innerHTML;
  
  var shader1 = new Shader(gl, fragmentShaderSource, vertexShaderSource);

  // Create a buffer for the square's positions.

  const positionBuffer = gl.createBuffer();

  // Select the positionBuffer as the one to apply buffer
  // operations to from here out.

  gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

  // Now create an array of positions for the square.

  const positions = [
    -1.0,  1.0, 0.0,
     1.0,  1.0, 0.0,
    -1.0, -1.0, 0.0,
     1.0, -1.0, 0.0,
  ];

  // Now pass the list of positions into WebGL to build the
  // shape. We do this by creating a Float32Array from the
  // JavaScript array, then use it to fill the current buffer.

  posAttribLocation = shader1.getAttribLocation("position");
  gl.enableVertexAttribArray(posAttribLocation);
  gl.vertexAttribPointer(posAttribLocation, 3, gl.FLOAT,false,0,0);
  gl.bufferData(gl.ARRAY_BUFFER,
                new Float32Array(positions),
                gl.STATIC_DRAW);

  //rb0 = gl.createRenderbuffer();
  //gl.bindRenderbuffer(gl.RENDERBUFFER, rb0);

  cloudTexture = new Texture(1024, 1024, gl);
  cloudTexture.render();

  

  function draw(){
    //resize canvas
    
    
    //
    gl.clearColor(1.0, 0.6, 0.0, 1.0);  // Clear to black, fully opaque
    gl.clearDepth(1.0);                 // Clear everything
    gl.enable(gl.DEPTH_TEST);           // Enable depth testing
    gl.depthFunc(gl.LEQUAL);            // Near things obscure far things
  
    // Clear the canvas before we start drawing on it.
  
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    shader1.use();
    newtime = new Date();
    timems = newtime.getTime() - start.getTime();
    time = timems/1000.;

    shader1.setUniform1f("u_time", time);
    shader1.setUniform2f("u_resolution", canvas.width, canvas.height);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
  }
  window.requestAnimationFrame(draw);
  start = new Date();
  gl.clearColor(.1,.1,1.,1.);
  gl.clearDepth(1.);
}
  

