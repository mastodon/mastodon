import React from 'react';
import PropTypes from 'prop-types';
import Button from '../../../components/button';
import ImmutablePureComponent from 'react-immutable-pure-component';
import Atrament from 'atrament'; // the doodling library

export default class DoodleModal extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    onDoodleSubmit: PropTypes.func.isRequired, // gets the base64 as argument
    onClose: PropTypes.func.isRequired,
  };

  handleKeyUp = (e) => {
    if (e.key === 'Delete' || e.key === 'Backspace') {
      this.clearScreen();
    }
  }

  clearScreen () {
    this.sketcher.context.fillStyle = 'white';
    this.sketcher.context.fillRect(0, 0, this.canvas.width, this.canvas.height);
  }

  componentDidMount () {
    window.addEventListener('keyup', this.handleKeyUp, false);
  }

  handleDone = () => {
    this.props.onDoodleSubmit(this.sketcher.toImage());
    this.sketcher.destroy();
    this.props.onClose();
  }

  setCanvasRef = (elem) => {
    this.canvas = elem;
    if (elem) {
      this.sketcher = new Atrament(elem, 500, 500, 'black');

      this.clearScreen();

      // .smoothing looks good with mouse but works really poorly with a tablet
      this.sketcher.smoothing = false;

      // There's a bunch of options we should add UI controls for later
      // ref: https://github.com/jakubfiala/atrament.js
    }
  }

  render () {
    return (
      <div className='modal-root__modal doodle-modal'>
        <div className='doodle-modal__container'>
          <canvas ref={this.setCanvasRef} />
        </div>

        <div className='doodle-modal__action-bar'>
          <Button text='Done' onClick={this.handleDone} />
        </div>
      </div>
    );
  }

}
