import PropTypes from 'prop-types';

import classNames from 'classnames';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import Atrament from 'atrament'; // the doodling library
import { debounce, mapValues } from 'lodash';

import ColorsIcon from '@/material-icons/400-24px/colors.svg?react';
import DeleteIcon from '@/material-icons/400-24px/delete.svg?react';
import EditIcon from '@/material-icons/400-24px/edit.svg?react';
import UndoIcon from '@/material-icons/400-24px/undo.svg?react';
import { doodleSet, uploadCompose } from 'flavours/glitch/actions/compose';
import { Button } from 'flavours/glitch/components/button';
import { IconButton } from 'flavours/glitch/components/icon_button';
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
/** Doodle canvas size options */
const DOODLE_SIZES = {
  normal: [500, 500, 'Square 500'],
  tootbanner: [702, 330, 'Tootbanner'],
  s640x480: [640, 480, '640×480 - 480p'],
  s800x600: [800, 600, '800×600 - SVGA'],
  s720x480: [720, 405, '720x405 - 16:9'],
};


const mapStateToProps = state => ({
  options: state.getIn(['compose', 'doodle']),
});

const mapDispatchToProps = dispatch => ({
  /**
   * Set options in the redux store
   * @param {Object} opts
   */
  setOpt: (opts) => dispatch(doodleSet(opts)),
  /**
   * Submit doodle for upload
   * @param {File} file
   */
  submit: (file) => dispatch(uploadCompose([file])),
});

/**
 * Doodling dialog with drawing canvas
 *
 * Keyboard shortcuts:
 * - Delete: Clear screen, fill with background color
 * - Backspace, Ctrl+Z: Undo one step
 * - Ctrl held while drawing: Use background color
 * - Shift held while clicking screen: Use fill tool
 *
 * Palette:
 * - Left mouse button: pick foreground
 * - Ctrl + left mouse button: pick background
 * - Right mouse button: pick background
 */
class DoodleModal extends ImmutablePureComponent {

  static propTypes = {
    options: ImmutablePropTypes.map,
    onClose: PropTypes.func.isRequired,
    setOpt: PropTypes.func.isRequired,
    submit: PropTypes.func.isRequired,
  };

  //region Option getters/setters

  /** Foreground color */
  get fg () {
    return this.props.options.get('fg');
  }
  set fg (value) {
    this.props.setOpt({ fg: value });
  }

  /** Background color */
  get bg () {
    return this.props.options.get('bg');
  }
  set bg (value) {
    this.props.setOpt({ bg: value });
  }

  /** Swap Fg and Bg for drawing */
  get swapped () {
    return this.props.options.get('swapped');
  }
  set swapped (value) {
    this.props.setOpt({ swapped: value });
  }

  /** Mode - 'draw' or 'fill' */
  get mode () {
    return this.props.options.get('mode');
  }
  set mode (value) {
    this.props.setOpt({ mode: value });
  }

  /** Base line weight */
  get weight () {
    return this.props.options.get('weight');
  }
  set weight (value) {
    this.props.setOpt({ weight: value });
  }

  /** Drawing opacity */
  get opacity () {
    return this.props.options.get('opacity');
  }
  set opacity (value) {
    this.props.setOpt({ opacity: value });
  }

  /** Adaptive stroke - change width with speed */
  get adaptiveStroke () {
    return this.props.options.get('adaptiveStroke');
  }
  set adaptiveStroke (value) {
    this.props.setOpt({ adaptiveStroke: value });
  }

  /** Smoothing (for mouse drawing) */
  get smoothing () {
    return this.props.options.get('smoothing');
  }
  set smoothing (value) {
    this.props.setOpt({ smoothing: value });
  }

  /** Size preset */
  get size () {
    return this.props.options.get('size');
  }
  set size (value) {
    this.props.setOpt({ size: value });
  }

  //endregion

  /**
   * Key up handler
   * @param {KeyboardEvent} e
   */
  handleKeyUp = (e) => {
    if (e.target.nodeName === 'INPUT') return;

    if (e.key === 'Delete') {
      e.preventDefault();
      this.handleClearBtn();
      return;
    }

    if (e.key === 'Backspace' || (e.key === 'z' && (e.ctrlKey || e.metaKey))) {
      e.preventDefault();
      this.undo();
    }

    if (e.key === 'Control' || e.key === 'Meta') {
      this.controlHeld = false;
      this.swapped = false;
    }

    if (e.key === 'Shift') {
      this.shiftHeld = false;
      this.mode = 'draw';
    }
  };

  /**
   * Key down handler
   * @param {KeyboardEvent} e
   */
  handleKeyDown = (e) => {
    if (e.key === 'Control' || e.key === 'Meta') {
      this.controlHeld = true;
      this.swapped = true;
    }

    if (e.key === 'Shift') {
      this.shiftHeld = true;
      this.mode = 'fill';
    }
  };

  /**
   * Component installed in the DOM, do some initial set-up
   */
  componentDidMount () {
    this.controlHeld = false;
    this.shiftHeld = false;
    this.swapped = false;
    window.addEventListener('keyup', this.handleKeyUp, false);
    window.addEventListener('keydown', this.handleKeyDown, false);
  }

  /**
   * Tear component down
   */
  componentWillUnmount () {
    window.removeEventListener('keyup', this.handleKeyUp, false);
    window.removeEventListener('keydown', this.handleKeyDown, false);
    if (this.sketcher) this.sketcher.destroy();
  }

  /**
   * Set reference to the canvas element.
   * This is called during component init
   * @param {HTMLCanvasElement} elem - canvas element
   */
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

      // prevent context menu
      elem.addEventListener('contextmenu', (e) => {
        e.preventDefault();
      });

      elem.addEventListener('mousedown', (e) => {
        if (e.button === 2) {
          this.swapped = true;
        }
      });

      elem.addEventListener('mouseup', (e) => {
        if (e.button === 2) {
          this.swapped = this.controlHeld;
        }
      });

      this.initSketcher(elem);
      this.mode = 'draw'; // Reset mode - it's confusing if left at 'fill'
    }
  };

  /**
   * Set up the sketcher instance
   * @param {HTMLCanvasElement | null} canvas - canvas element. Null if we're just resizing
   */
  initSketcher (canvas = null) {
    const sizepreset = DOODLE_SIZES[this.size];

    if (this.sketcher) this.sketcher.destroy();
    this.sketcher = new Atrament(canvas || this.canvas, sizepreset[0], sizepreset[1]);

    if (canvas) {
      this.ctx = this.sketcher.context;
      this.updateSketcherSettings();
    }

    this.clearScreen();
  }

  /**
   * Done button handler
   */
  onDoneButton = () => {
    const dataUrl = this.sketcher.toImage();
    const file = dataURLtoFile(dataUrl, 'doodle.png');
    this.props.submit(file);
    this.props.onClose(); // close dialog
  };

  /**
   * Cancel button handler
   */
  onCancelButton = () => {
    if (this.undos.length > 1 && !confirm('Discard doodle? All changes will be lost!')) {
      return;
    }

    this.props.onClose(); // close dialog
  };

  /**
   * Update sketcher options based on state
   */
  updateSketcherSettings () {
    if (!this.sketcher) return;

    if (this.oldSize !== this.size) this.initSketcher();

    this.sketcher.color = (this.swapped ? this.bg : this.fg);
    this.sketcher.opacity = this.opacity;
    this.sketcher.weight = this.weight;
    this.sketcher.mode = this.mode;
    this.sketcher.smoothing = this.smoothing;
    this.sketcher.adaptiveStroke = this.adaptiveStroke;

    this.oldSize = this.size;
  }

  /**
   * Fill screen with background color
   */
  clearScreen = () => {
    this.ctx.fillStyle = this.bg;
    this.ctx.fillRect(-1, -1, this.canvas.width+2, this.canvas.height+2);
    this.undos = [];

    this.doSaveUndo();
  };

  /**
   * Undo one step
   */
  undo = () => {
    if (this.undos.length > 1) {
      this.undos.pop();
      const buf = this.undos.pop();

      this.sketcher.clear();
      this.ctx.putImageData(buf, 0, 0);
      this.doSaveUndo();
    }
  };

  /**
   * Save canvas content into the undo buffer immediately
   */
  doSaveUndo = () => {
    this.undos.push(this.ctx.getImageData(0, 0, this.canvas.width, this.canvas.height));
  };

  /**
   * Called on each canvas change.
   * Saves canvas content to the undo buffer after some period of inactivity.
   */
  saveUndo = debounce(() => {
    this.doSaveUndo();
  }, 100);

  /**
   * Palette left click.
   * Selects Fg color (or Bg, if Control/Meta is held)
   * @param {MouseEvent<HTMLButtonElement>} e - event
   */
  onPaletteClick = (e) => {
    const c = e.target.dataset.color;

    if (this.controlHeld) {
      this.bg = c;
    } else {
      this.fg = c;
    }

    e.target.blur();
    e.preventDefault();
  };

  /**
   * Palette right click.
   * Selects Bg color
   * @param {MouseEvent<HTMLButtonElement>} e - event
   */
  onPaletteRClick = (e) => {
    this.bg = e.target.dataset.color;
    e.target.blur();
    e.preventDefault();
  };

  /**
   * Handle click on the Draw mode button
   * @param {MouseEvent<HTMLButtonElement>} e - event
   */
  setModeDraw = (e) => {
    this.mode = 'draw';
    e.target.blur();
  };

  /**
   * Handle click on the Fill mode button
   * @param {MouseEvent<HTMLButtonElement>} e - event
   */
  setModeFill = (e) => {
    this.mode = 'fill';
    e.target.blur();
  };

  /**
   * Handle click on Smooth checkbox
   * @param {ChangeEvent<HTMLInputElement>} e - event
   */
  tglSmooth = (e) => {
    this.smoothing = !this.smoothing;
    e.target.blur();
  };

  /**
   * Handle click on Adaptive checkbox
   * @param {ChangeEvent<HTMLInputElement>} e - event
   */
  tglAdaptive = (e) => {
    this.adaptiveStroke = !this.adaptiveStroke;
    e.target.blur();
  };

  /**
   * Handle change of the Weight input field
   * @param {ChangeEvent<HTMLInputElement>} e - event
   */
  setWeight = (e) => {
    this.weight = +e.target.value || 1;
  };

  /**
   * Set size - clalback from the select box
   * @param {ChangeEvent<HTMLSelectElement>} e - event
   */
  changeSize = (e) => {
    let newSize = e.target.value;
    if (newSize === this.oldSize) return;

    if (this.undos.length > 1 && !confirm('Change canvas size? This will erase your current drawing!')) {
      return;
    }

    this.size = newSize;
  };

  handleClearBtn = () => {
    if (this.undos.length > 1 && !confirm('Clear canvas? This will erase your current drawing!')) {
      return;
    }

    this.clearScreen();
  };

  /**
   * Render the component
   */
  render () {
    this.updateSketcherSettings();

    return (
      <div className='modal-root__modal doodle-modal'>
        <div className='doodle-modal__container'>
          <canvas ref={this.setCanvasRef} />
        </div>

        <div className='doodle-modal__action-bar'>
          <div className='doodle-toolbar'>
            <Button text='Done' onClick={this.onDoneButton} />
            <Button text='Cancel' onClick={this.onCancelButton} />
          </div>
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
            <div>
              <select aria-label='Canvas size' onInput={this.changeSize} defaultValue={this.size}>
                { Object.values(mapValues(DOODLE_SIZES, (val, k) =>
                  <option key={k} value={k}>{val[2]}</option>,
                )) }
              </select>
            </div>
          </div>
          <div className='doodle-toolbar'>
            <IconButton icon='pencil' iconComponent={EditIcon} title='Draw' label='Draw' onClick={this.setModeDraw} size={18} active={this.mode === 'draw'} inverted />
            <IconButton icon='bath' iconComponent={ColorsIcon} title='Fill' label='Fill' onClick={this.setModeFill} size={18} active={this.mode === 'fill'} inverted />
            <IconButton icon='undo' iconComponent={UndoIcon} title='Undo' label='Undo' onClick={this.undo} size={18} inverted />
            <IconButton icon='trash' iconComponent={DeleteIcon} title='Clear' label='Clear' onClick={this.handleClearBtn} size={18} inverted />
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
                    onContextMenu={this.onPaletteRClick}
                    data-color={c[0]}
                    title={c[1]}
                    className={classNames({
                      'foreground': this.fg === c[0],
                      'background': this.bg === c[0],
                    })}
                  />,
              )
            }
          </div>
        </div>
      </div>
    );
  }

}

export default connect(mapStateToProps, mapDispatchToProps)(DoodleModal);
