
window.onload = function init() {
  const canvas = document.querySelector("#glCanvas");
  // Initialize the GL context
  const gl = canvas.getContext("webgl");

  // Only continue if WebGL is available and working
  if (gl === null) {
    alert("Unable to initialize WebGL. Your browser or machine may not support it.");
    return;
  }

function createShader (gl, sourceCode, type) {
  // Compiles either a shader of type gl.VERTEX_SHADER or gl.FRAGMENT_SHADER
  var shader = gl.createShader( type );
  gl.shaderSource( shader, sourceCode );
  gl.compileShader( shader );

  if ( !gl.getShaderParameter(shader, gl.COMPILE_STATUS) ) {
    var info = gl.getShaderInfoLog( shader );
    throw 'Could not compile WebGL program. \n\n' + info;
  }
  return shader;
}

  var vertexShaderSource =
  'attribute vec4 position;\n' +
  'void main() {\n' +
  '  gl_Position = position;\n' +
  '}\n';


  //Use the createShader function from the example above
  var vertexShader = createShader(gl, vertexShaderSource, gl.VERTEX_SHADER)
  

  var fragmentShaderSource = document.getElementById('fragment').innerHTML;
  var fragmentShader = createShader(gl, fragmentShaderSource, gl.FRAGMENT_SHADER);

  var program = gl.createProgram();

  // Attach pre-existing shaders
  gl.attachShader(program, vertexShader);
  gl.attachShader(program, fragmentShader);

  gl.linkProgram(program);

  if ( !gl.getProgramParameter( program, gl.LINK_STATUS) ) {
    var info = gl.getProgramInfoLog(program);
    throw 'Could not compile WebGL program. \n\n' + info;
  }

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

  posAttribLocation = gl.getAttribLocation(program, "position");
  gl.enableVertexAttribArray(posAttribLocation);
  gl.vertexAttribPointer(posAttribLocation, 3, gl.FLOAT,false,0,0);
  gl.bufferData(gl.ARRAY_BUFFER,
                new Float32Array(positions),
                gl.STATIC_DRAW);

  var u_resolution = gl.getUniformLocation(program,"u_resolution");
  var u_time = gl.getUniformLocation(program,"u_time");


function draw(){
  console.log("asd");
  gl.clearColor(1.0, 0.6, 0.0, 1.0);  // Clear to black, fully opaque
  gl.clearDepth(1.0);                 // Clear everything
  gl.enable(gl.DEPTH_TEST);           // Enable depth testing
  gl.depthFunc(gl.LEQUAL);            // Near things obscure far things

  // Clear the canvas before we start drawing on it.

  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

  // Tell WebGL to use our program when drawing

  gl.useProgram(program);

  newtime = new Date();
  timems = newtime.getTime() - start.getTime();
  time = timems/1000.;
  console.log(time);
  gl.uniform1f(u_time,time);
  console.log(window.innerWidth);
	
  gl.uniform2fv(u_resolution,[window.innerWidth, window.innerHeight]);
  gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
  window.requestAnimationFrame(draw);
}
  window.requestAnimationFrame(draw);
  start = new Date();
  // Set clear color to black, fully opaque
  gl.clearColor(0.0, 0.0, 0.0, 1.0);
  // Clear the color buffer with specified clear color
  gl.clear(gl.COLOR_BUFFER_BIT);
}

