import React from 'react';
import PropTypes from 'prop-types';
import Button from '../../../components/button';
import ImmutablePureComponent from 'react-immutable-pure-component';
import Atrament from 'atrament'; // the doodling library
import { connect } from 'react-redux';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { doodleSet, uploadCompose } from '../../../actions/compose';
import IconButton from '../../../components/icon_button';
import { debounce } from 'lodash';

// palette nicked from MyPaint, CC0
const palette = [
  ['rgb(  0,    0,    0)', 'Black'],
  ['rgb( 38,   38,   38)', 'Gray 15'],
  ['rgb( 77,   77,   77)', 'Grey 30'],
  ['rgb(128,  128,  128)', 'Grey 50'],
  ['rgb(171,  171,  171)', 'Grey 67'],
  ['rgb(217,  217,  217)', 'Grey 85'],
  ['rgb(255,  255,  255)', 'White'],
  ['rgb(128,    0,    0)', 'Maroon'],
  ['rgb(209,    0,    0)', 'English-red'],
  ['rgb(255,   54,   34)', 'Tomato'],
  ['rgb(252,   60,    3)', 'Orange-red'],
  ['rgb(255,  140,  105)', 'Salmon'],
  ['rgb(252,  232,   32)', 'Cadium-yellow'],
  ['rgb(243,  253,   37)', 'Lemon yellow'],
  ['rgb(121,    5,   35)', 'Dark crimson'],
  ['rgb(169,   32,   62)', 'Deep carmine'],
  ['rgb(255,  140,    0)', 'Orange'],
  ['rgb(255,  168,   18)', 'Dark tangerine'],
  ['rgb(217,  144,   88)', 'Persian orange'],
  ['rgb(194,  178,  128)', 'Sand'],
  ['rgb(255,  229,  180)', 'Peach'],
  ['rgb(100,   54,   46)', 'Bole'],
  ['rgb(108,   41,   52)', 'Dark cordovan'],
  ['rgb(163,   65,   44)', 'Chestnut'],
  ['rgb(228,  136,  100)', 'Dark salmon'],
  ['rgb(255,  195,  143)', 'Apricot'],
  ['rgb(255,  219,  188)', 'Unbleached silk'],
  ['rgb(242,  227,  198)', 'Straw'],
  ['rgb( 53,   19,   13)', 'Bistre'],
  ['rgb( 84,   42,   14)', 'Dark chocolate'],
  ['rgb(102,   51,   43)', 'Burnt sienna'],
  ['rgb(184,   66,    0)', 'Sienna'],
  ['rgb(216,  153,   12)', 'Yellow ochre'],
  ['rgb(210,  180,  140)', 'Tan'],
  ['rgb(232,  204,  144)', 'Dark wheat'],
  ['rgb(  0,   49,   83)', 'Prussian blue'],
  ['rgb( 48,   69,  119)', 'Dark grey blue'],
  ['rgb(  0,   71,  171)', 'Cobalt blue'],
  ['rgb( 31,  117,  254)', 'Blue'],
  ['rgb(120,  180,  255)', 'Bright french blue'],
  ['rgb(171,  200,  255)', 'Bright steel blue'],
  ['rgb(208,  231,  255)', 'Ice blue'],
  ['rgb( 30,   51,   58)', 'Medium jungle green'],
  ['rgb( 47,   79,   79)', 'Dark slate grey'],
  ['rgb( 74,  104,   93)', 'Dark grullo green'],
  ['rgb(  0,  128,  128)', 'Teal'],
  ['rgb( 67,  170,  176)', 'Turquoise'],
  ['rgb(109,  174,  199)', 'Cerulean frost'],
  ['rgb(173,  217,  186)', 'Tiffany green'],
  ['rgb( 22,   34,   29)', 'Gray-asparagus'],
  ['rgb( 36,   48,   45)', 'Medium dark teal'],
  ['rgb( 74,  104,   93)', 'Xanadu'],
  ['rgb(119,  198,  121)', 'Mint'],
  ['rgb(175,  205,  182)', 'Timberwolf'],
  ['rgb(185,  245,  246)', 'Celeste'],
  ['rgb(193,  255,  234)', 'Aquamarine'],
  ['rgb( 29,   52,   35)', 'Cal Poly Pomona'],
  ['rgb(  1,   68,   33)', 'Forest green'],
  ['rgb( 42,  128,    0)', 'Napier green'],
  ['rgb(128,  128,    0)', 'Olive'],
  ['rgb( 65,  156,  105)', 'Sea green'],
  ['rgb(189,  246,   29)', 'Green-yellow'],
  ['rgb(231,  244,  134)', 'Bright chartreuse'],
  ['rgb(138,   23,  137)', 'Purple'],
  ['rgb( 78,   39,  138)', 'Violet'],
  ['rgb(193,   75,  110)', 'Dark thulian pink'],
  ['rgb(222,   49,   99)', 'Cerise'],
  ['rgb(255,   20,  147)', 'Deep pink'],
  ['rgb(255,  102,  204)', 'Rose pink'],
  ['rgb(255,  203,  219)', 'Pink'],
  ['rgb(255,  255,  255)', 'White'],
  ['rgb(229,   17,    1)', 'RGB Red'],
  ['rgb(  0,  255,    0)', 'RGB Green'],
  ['rgb(  0,    0,  255)', 'RGB Blue'],
  ['rgb(  0,  255,  255)', 'CMYK Cyan'],
  ['rgb(255,    0,  255)', 'CMYK Magenta'],
  ['rgb(255,  255,    0)', 'CMYK Yellow'],
];

// re-arrange to the right order for display
let palReordered = [];
for (let row = 0; row < 7; row++) {
  for (let col = 0; col < 11; col++) {
    palReordered.push(palette[col * 7 + row]);
  }
  palReordered.push(null); // null indicates a <br />
}

// Utility for converting base64 image to binary for upload
// https://stackoverflow.com/questions/35940290/how-to-convert-base64-string-to-javascript-file-object-like-as-from-file-input-f
function dataURLtoFile(dataurl, filename) {
  let arr = dataurl.split(','), mime = arr[0].match(/:(.*?);/)[1],
    bstr = atob(arr[1]), n = bstr.length, u8arr = new Uint8Array(n);
  while(n--){
    u8arr[n] = bstr.charCodeAt(n);
  }
  return new File([u8arr], filename, { type: mime });
}


const mapStateToProps = state => ({
  options: state.getIn(['compose', 'doodle']),
});

const mapDispatchToProps = dispatch => ({
  setOpt: (opts) => dispatch(doodleSet(opts)),
  submit: (file) => dispatch(uploadCompose([file])),
});

@connect(mapStateToProps, mapDispatchToProps)
export default class DoodleModal extends ImmutablePureComponent {

  static propTypes = {
    options: ImmutablePropTypes.map,
    onClose: PropTypes.func.isRequired,
    setOpt: PropTypes.func.isRequired,
    submit: PropTypes.func.isRequired,
  };

  //region Option getters/setters

  get fg () {
    return this.props.options.get('fg');
  }

  set fg (value) {
    this.props.setOpt({ fg: value });
  }

  get bg () {
    return this.props.options.get('bg');
  }

  set bg (value) {
    this.props.setOpt({ bg: value });
  }

  get mode () {
    return this.props.options.get('mode');
  }

  set mode (value) {
    this.props.setOpt({ mode: value });
  }

  get weight () {
    return this.props.options.get('weight');
  }

  set weight (value) {
    this.props.setOpt({ weight: value });
  }

  get opacity () {
    return this.props.options.get('opacity');
  }

  set opacity (value) {
    this.props.setOpt({ opacity: value });
  }

  get adaptiveStroke () {
    return this.props.options.get('adaptiveStroke');
  }

  set adaptiveStroke (value) {
    this.props.setOpt({ adaptiveStroke: value });
  }

  get smoothing () {
    return this.props.options.get('smoothing');
  }

  set smoothing (value) {
    this.props.setOpt({ smoothing: value });
  }

  //endregion

  handleKeyUp = (e) => {
    if (e.key === 'Delete' || e.key === 'Backspace') {
      e.preventDefault();
      this.clearScreen();
    }

    if (e.key === 'z' && (e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      this.undo();
    }
  };

  componentDidMount () {
    window.addEventListener('keyup', this.handleKeyUp, false);
  };

  componentWillUnmount () {
    window.removeEventListener('keyup', this.handleKeyUp, false);
  }

  clearScreen = () => {
    this.sketcher.context.fillStyle = this.bg;
    this.sketcher.context.fillRect(0, 0, this.canvas.width, this.canvas.height);
    this.undos = [];

    this.doSaveUndo();
  };

  handleDone = () => {
    const dataUrl = this.sketcher.toImage();
    const file = dataURLtoFile(dataUrl, 'doodle.png');
    this.props.submit(file);

    this.sketcher.destroy();
    this.props.onClose();
  };

  updateSketcherSettings () {
    if (!this.sketcher) return;

    this.sketcher.color = this.fg;
    this.sketcher.opacity = this.opacity;
    this.sketcher.weight = this.weight;
    this.sketcher.mode = this.mode;
    this.sketcher.smoothing = this.smoothing;
    this.sketcher.adaptiveStroke = this.adaptiveStroke;
  }

  initSketcher (elem) {
    this.sketcher = new Atrament(elem, 500, 500);

    this.mode = 'draw'; // Reset mode - it's confusing if left at 'fill'

    this.updateSketcherSettings();
    this.clearScreen();
  }

  setCanvasRef = (elem) => {
    this.canvas = elem;
    if (elem) {
      elem.addEventListener('dirty', () => {
        this.saveUndo();
        this.sketcher._dirty = false;
      });
      elem.addEventListener('click', () => {
        // sketcher bug - does not fire dirty on fill
        if (this.mode === 'fill') {
          this.saveUndo();
        }
      });

      this.initSketcher(elem);
    }
  };

  onPaletteClick = (e) => {
    this.fg = e.target.dataset.color;
    e.target.blur();
  };

  setModeDraw = (e) => {
    this.mode = 'draw';
    e.target.blur();
  };

  setModeFill = (e) => {
    this.mode = 'fill';
    e.target.blur();
  };

  tglSmooth = (e) => {
    this.smoothing = !this.smoothing;
    e.target.blur();
  };

  tglAdaptive = (e) => {
    this.adaptiveStroke = !this.adaptiveStroke;
    e.target.blur();
  };

  setWeight = (e) => {
    this.weight = +e.target.value || 1;
  };

  undo = () => {
    if (this.undos.length > 1) {
      this.undos.pop();
      const buf = this.undos.pop();

      this.sketcher.clear();
      this.sketcher.context.putImageData(buf, 0, 0);
      this.doSaveUndo();
    }
  };

  doSaveUndo = () => {
    this.undos.push(this.sketcher.context.getImageData(0, 0, this.canvas.width, this.canvas.height));
  };

  saveUndo = debounce(() => {
    this.doSaveUndo();
  }, 100);

  render () {
    this.updateSketcherSettings();

    return (
      <div className='modal-root__modal doodle-modal'>
        <div className='doodle-modal__container'>
          <canvas ref={this.setCanvasRef} />
        </div>

        <div className='doodle-modal__action-bar'>
          <Button text='Done' onClick={this.handleDone} />
          <div className='filler' />
          <div className='doodle-toolbar with-inputs'>
            <div>
              <label htmlFor='dd_smoothing'>Smoothing</label>
              <span className='val'>
                <input type='checkbox' id='dd_smoothing' onChange={this.tglSmooth} checked={this.smoothing} />
              </span>
            </div>
            <div>
              <label htmlFor='dd_adaptive'>Adaptive</label>
              <span className='val'>
                <input type='checkbox' id='dd_adaptive' onChange={this.tglAdaptive} checked={this.adaptiveStroke} />
              </span>
            </div>
            <div>
              <label htmlFor='dd_weight'>Weight</label>
              <span className='val'>
                <input type='number' min={1} id='dd_weight' value={this.weight} onChange={this.setWeight} />
              </span>
            </div>
          </div>
          <div className='doodle-toolbar'>
            <IconButton icon='pencil' label='Draw' onClick={this.setModeDraw} size={18} active={this.mode === 'draw'} inverted />
            <IconButton icon='bath' label='Fill' onClick={this.setModeFill} size={18} active={this.mode === 'fill'} inverted />
            <IconButton icon='undo' label='Undo' onClick={this.undo} size={18} inverted />
            <IconButton icon='trash' label='Clear' onClick={this.clearScreen} size={18} inverted />
          </div>
          <div className='doodle-palette'>
            {
              palReordered.map((c, i) =>
                c === null ?
                  <br key={i} /> :
                  <button
                    key={i}
                    style={{ backgroundColor: c[0] }}
                    onClick={this.onPaletteClick}
                    data-color={c[0]}
                    title={c[1]}
                    className={this.fg === c[0] ? 'selected' : ''}
                  />
              )
            }
          </div>
        </div>
      </div>
    );
  }

}
