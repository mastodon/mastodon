import PureRenderMixin from 'react-addons-pure-render-mixin';

// From: http://stackoverflow.com/a/18320662
const resample = (canvas, width, height, resize_canvas) => {
  let width_source  = canvas.width;
  let height_source = canvas.height;
  width  = Math.round(width);
  height = Math.round(height);

  let ratio_w      = width_source / width;
  let ratio_h      = height_source / height;
  let ratio_w_half = Math.ceil(ratio_w / 2);
  let ratio_h_half = Math.ceil(ratio_h / 2);

  let ctx   = canvas.getContext("2d");
  let img   = ctx.getImageData(0, 0, width_source, height_source);
  let img2  = ctx.createImageData(width, height);
  let data  = img.data;
  let data2 = img2.data;

  for (let j = 0; j < height; j++) {
    for (let i = 0; i < width; i++) {
      let x2            = (i + j * width) * 4;
      let weight        = 0;
      let weights       = 0;
      let weights_alpha = 0;
      let gx_r          = 0;
      let gx_g          = 0;
      let gx_b          = 0;
      let gx_a          = 0;
      let center_y      = (j + 0.5) * ratio_h;
      let yy_start      = Math.floor(j * ratio_h);
      let yy_stop       = Math.ceil((j + 1) * ratio_h);

      for (let yy = yy_start; yy < yy_stop; yy++) {
        let dy       = Math.abs(center_y - (yy + 0.5)) / ratio_h_half;
        let center_x = (i + 0.5) * ratio_w;
        let w0       = dy * dy; //pre-calc part of w
        let xx_start = Math.floor(i * ratio_w);
        let xx_stop  = Math.ceil((i + 1) * ratio_w);

        for (let xx = xx_start; xx < xx_stop; xx++) {
          let dx = Math.abs(center_x - (xx + 0.5)) / ratio_w_half;
          let w  = Math.sqrt(w0 + dx * dx);

          if (w >= 1) {
            // pixel too far
            continue;
          }

          // hermite filter
          weight    = 2 * w * w * w - 3 * w * w + 1;
          let pos_x = 4 * (xx + yy * width_source);

          // alpha
          gx_a          += weight * data[pos_x + 3];
          weights_alpha += weight;

          // colors
          if (data[pos_x + 3] < 255)
            weight = weight * data[pos_x + 3] / 250;

          gx_r    += weight * data[pos_x];
          gx_g    += weight * data[pos_x + 1];
          gx_b    += weight * data[pos_x + 2];
          weights += weight;
        }
      }

      data2[x2]     = gx_r / weights;
      data2[x2 + 1] = gx_g / weights;
      data2[x2 + 2] = gx_b / weights;
      data2[x2 + 3] = gx_a / weights_alpha;
    }
  }

  // clear and resize canvas
  if (resize_canvas === true) {
    canvas.width  = width;
    canvas.height = height;
  } else {
    ctx.clearRect(0, 0, width_source, height_source);
  }

  // draw
  ctx.putImageData(img2, 0, 0);
};

const Avatar = React.createClass({

  propTypes: {
    src: React.PropTypes.string.isRequired,
    size: React.PropTypes.number.isRequired,
    style: React.PropTypes.object
  },

  getInitialState () {
    return {
      hovering: false
    };
  },

  mixins: [PureRenderMixin],

  handleMouseEnter () {
    this.setState({ hovering: true });
  },

  handleMouseLeave () {
    this.setState({ hovering: false });
  },

  handleLoad () {
    this.canvas.width  = this.image.naturalWidth;
    this.canvas.height = this.image.naturalHeight;
    this.canvas.getContext('2d').drawImage(this.image, 0, 0);

    resample(this.canvas, this.props.size * window.devicePixelRatio, this.props.size * window.devicePixelRatio, true);
  },

  setImageRef (c) {
    this.image = c;
  },

  setCanvasRef (c) {
    this.canvas = c;
  },

  render () {
    const { hovering } = this.state;

    return (
      <div onMouseEnter={this.handleMouseEnter} onMouseLeave={this.handleMouseLeave} style={{ ...this.props.style, width: `${this.props.size}px`, height: `${this.props.size}px`, position: 'relative' }}>
        <img ref={this.setImageRef} crossOrigin='anonymous' onLoad={this.handleLoad} src={this.props.src} width={this.props.size} height={this.props.size} alt='' style={{ position: 'absolute', top: '0', left: '0', opacity: hovering ? '1' : '0', borderRadius: '4px' }} />
        <canvas ref={this.setCanvasRef} style={{ borderRadius: '4px', width: this.props.size, height: this.props.size, opacity: hovering ? '0' : '1' }} />
      </div>
    );
  }

});

export default Avatar;
