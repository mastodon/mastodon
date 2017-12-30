import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import Motion from '../util/optional_motion';
import spring from 'react-motion/lib/spring';
import { mat4 } from 'gl-matrix';

const MAX_ZOOM = 50;
const INITIAL_ZOOM = 0.8;
const MIN_ZOOM = 0.4;
const WHEEL_ZOOM_SPEED = 0.01;
const PAN_SPEED = 2;

// shaders and projection adapted from https://github.com/google/marzipano/tree/5632cd6d3b5ddeb49939aee96e97c24f68874aee
export default class PanoramaViewer extends React.PureComponent {

  static propTypes = {
    image: PropTypes.object.isRequired,
    width: PropTypes.number.isRequired,
    height: PropTypes.number.isRequired,
    alt: PropTypes.string,
    className: PropTypes.string,
  }

  state = {
    x: 0,
    y: 0,
    zoom: INITIAL_ZOOM,
    sphere: true,
  }

  sphere = 0

  get webGLContext() {
    if (!this.canvas) return null;
    this._webGLContext = this._webGLContext || this.canvas.getContext('webgl') || this.canvas.getContext('experimental-webgl');
    return this._webGLContext;
  }

  componentDidMount () {
    this.initWebGL();
  }

  setCanvasRef = canvas => {
    this.canvas = canvas;

    if (canvas) {
      // bind WebKit gesture events here because React won't do it
      canvas.addEventListener('gesturestart', this.onGestureStart);
      canvas.addEventListener('gesturechange', this.onGestureChange);
    }
  }

  componentWillUnmount () {
    if (this.canvas) {
      this.canvas.removeEventListener('gesturestart', this.onGestureStart);
      this.canvas.removeEventListener('gesturechange', this.onGestureStart);
    }

    if (this.mouseDown) this.onMouseUp();
  }

  onMouseDown = e => {
    this.lastMousePos = [e.clientX, e.clientY];
    this.mouseDown = true;

    window.addEventListener('mousemove', this.onMouseMove);
    window.addEventListener('mouseup', this.onMouseUp);
  }

  onMouseMove = e => {
    if (!this.mouseDown) return;
    let deltaX = e.clientX - this.lastMousePos[0];
    let deltaY = e.clientY - this.lastMousePos[1];
    let x = this.state.x + PAN_SPEED * deltaX / this.props.width / this.state.zoom;
    let y = this.state.y + PAN_SPEED * deltaY / this.props.height / this.state.zoom;
    this.setState({ x, y });
    this.lastMousePos = [e.clientX, e.clientY];
  }

  onMouseUp = () => {
    this.mouseDown = false;

    window.removeEventListener('mousemove', this.onMouseMove);
    window.removeEventListener('mouseup', this.onMouseUp);
  }

  onWheel = e => {
    e.preventDefault();

    let zoomDelta = 1 - (e.deltaY * WHEEL_ZOOM_SPEED);
    this.setState({
      zoom: Math.max(MIN_ZOOM, Math.min(this.state.zoom * zoomDelta, MAX_ZOOM)),
    });
  }

  onGestureStart = e => {
    e.preventDefault();

    this.zoomAtGestureStart = this.state.zoom;
  }

  onGestureChange = e => {
    e.preventDefault();

    this.setState({
      zoom: Math.max(MIN_ZOOM, Math.min(this.zoomAtGestureStart * e.scale, MAX_ZOOM)),
    });
  }

  render () {
    const className = classNames('panorama-viewer', this.props.className || '');

    this.draw();

    return (
      <div className={className}>
        <canvas
          className='panorama-viewer__canvas'
          width={this.props.width}
          height={this.props.height}
          ref={this.setCanvasRef}

          onMouseDown={this.onMouseDown}
          onWheel={this.onWheel}
        />
        <Motion
          defaultStyle={{ sphere: 0 }}
          style={{ sphere: spring(+this.state.sphere) }}
        >
          {({ sphere }) => {
            this.sphere = sphere;
            this.draw();
            return '';
          }}
        </Motion>
      </div>
    );
  }

  initWebGL () {
    const gl = this.webGLContext;

    if (!gl) return;

    this.resizeContext();

    gl.clearColor(0, 0, 0, 0);
    gl.clear(gl.COLOR_BUFFER_BIT);

    let shader = this.compileShader(`
precision mediump float;
attribute vec2 position;
uniform mat4 invProj;
varying vec4 ray;
varying vec2 pos;
void main() {
  gl_Position = vec4(position, 0., 1.);
  ray = invProj * vec4(position, 1., 1.);
  pos = position;
}`, `
precision highp float;
varying vec4 ray;
varying vec2 pos;
uniform vec2 aspect;
uniform sampler2D texture;
uniform float sphere;
const float PI = 3.14159265358979323846264;
void main() {
  float r = inversesqrt(ray.x * ray.x + ray.y * ray.y + ray.z * ray.z);
  float phi  = acos(ray.y * r);
  float theta = atan(ray.x, -ray.z);
  float s = 0.5 + 0.5 * theta / PI;
  float t = 1. - phi / PI;

  vec2 tex_pos = mix(vec2(1, -1) * pos / 2. + vec2(.5), vec2(s, 1. - t), sphere);
  gl_FragColor = texture2D(texture, tex_pos);
}
    `);

    let buffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([
      1, 1,
      -1, 1,
      1, -1,
      -1, -1,
    ]), gl.DYNAMIC_DRAW);

    gl.useProgram(shader);

    let shaderAttribPosition = gl.getAttribLocation(shader, 'position');
    let shaderUniformTexture = gl.getUniformLocation(shader, 'texture');
    this.shaderUniformInvProj = gl.getUniformLocation(shader, 'invProj');
    this.shaderUniformSphere = gl.getUniformLocation(shader, 'sphere');

    let aspect = this.props.image.width / this.props.image.height;
    let aspectWidth = aspect < 1 ? 1 : aspect;
    let aspectHeight = aspect > 1 ? 1 : aspect;

    gl.uniform2f(gl.getUniformLocation(shader, 'aspect'), aspectWidth, aspectHeight);

    gl.activeTexture(gl.TEXTURE0);
    gl.uniform1i(shaderUniformTexture, 0);

    gl.vertexAttribPointer(shaderAttribPosition, 2, gl.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(shaderAttribPosition);

    let texture = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, texture);

    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, this.props.image);

    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

    this.drawOffset(0, 0);
  }

  updateProjection (x, y) {
    const gl = this.webGLContext;
    if (!gl) return;

    const projection = mat4.create();
    const fov = 1 / this.state.zoom;
    const aspect = this.props.width / this.props.height;
    mat4.perspective(projection, fov, aspect, -1, 1);
    mat4.rotateX(projection, projection, -y);
    mat4.rotateY(projection, projection, -x);
    mat4.invert(projection, projection);

    gl.uniform1f(this.shaderUniformSphere, this.sphere);
    gl.uniformMatrix4fv(this.shaderUniformInvProj, false, projection);
  }

  drawBuffer () {
    const gl = this.webGLContext;
    if (!gl) return;
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
  }

  drawOffset (x, y) {
    const gl = this.webGLContext;
    if (!gl) return;

    this.updateProjection(x, y);
    this.drawBuffer();
  }

  draw () {
    this.drawOffset(this.state.x, this.state.y);
  }

  compileShader (vertex, fragment) {
    const gl = this.webGLContext;

    if (!gl) return null;

    let vert = gl.createShader(gl.VERTEX_SHADER);
    gl.shaderSource(vert, vertex);
    gl.compileShader(vert);

    let frag = gl.createShader(gl.FRAGMENT_SHADER);
    gl.shaderSource(frag, fragment);
    gl.compileShader(frag);

    if (!gl.getShaderParameter(vert, gl.COMPILE_STATUS) || !gl.getShaderParameter(frag, gl.COMPILE_STATUS)) {
      let error = gl.getShaderInfoLog(vert) + '\n\n' + gl.getShaderInfoLog(frag);
      gl.deleteShader(vert);
      gl.deleteShader(frag);
      throw new Error(error);
    }

    let shader = gl.createProgram();
    gl.attachShader(shader, vert);
    gl.attachShader(shader, frag);
    gl.linkProgram(shader);

    if (!gl.getProgramParameter(shader, gl.LINK_STATUS)) {
      gl.deleteProgram(shader);
      throw new Error(gl.getProgramInfoLog(shader));
    }

    return shader;
  }

  resizeContext () {
    const gl = this.webGLContext;
    const { width, height } = this.props;

    if (!gl) return;

    gl.viewport(0, 0, width, height);
  }

}
