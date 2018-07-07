import React from 'react';
import {playerName as name} from '../../../initial_state';
import {connect} from 'react-redux';
import classNames from 'classnames';
import * as playerActions from "../../../actions/audio_player";

@connect(state => ({...state.get('audioPlayer')}), (dispatch) => ({
  setPaused: () => dispatch(playerActions.setPaused()),
  setPlaying: () => dispatch(playerActions.setPlaying()),
}))
export default class ColumnPlayer extends React.Component {

  constructor(props) {
    super(props);
  }

  isSafariShit = () => {
    return this.props.error && this.props.error.code === 4;
  };

  handleButtonClick = () => {
    if (this.isSafariShit()) {
      return;
    }
    if (this.props.isPlaying) {
      this.props.setPaused()
    }
    else if (this.props.isPlaying === false) {
      this.props.setPlaying();
    }
  }

  render() {
    return (<React.Fragment>
      <div className={classNames('column-player', {'playing': this.props.isPlaying})}>
        <button className={'column-player__toggle'} onClick={this.handleButtonClick}>
          <i
            className={classNames(
              'fa fa-fw',
              {'fa-play': this.props.isPlaying === false},
              {'fa-pause': this.props.isPlaying},
              {'fa-exclamation-triangle': this.props.error && this.props.error.code === 4},
              {'fa-spinner fa-spin': this.props.isLoading && this.props.error && this.props.error.code !== 4})}
          />
        </button>
        <span>{name}</span>
      </div>
    </React.Fragment>);
  }

}
