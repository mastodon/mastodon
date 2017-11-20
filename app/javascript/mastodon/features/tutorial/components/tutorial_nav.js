import React from 'react';
import PropTypes from 'prop-types';

export default class TutorialNav extends React.Component {

  static propTypes = {
    tutorialSkip: PropTypes.func.isRequired,
    tutorialNextPage: PropTypes.func.isRequired,
    navText: PropTypes.string.isRequired,
    isLast: PropTypes.bool,
  };

  tutorialSkip = () => {
    this.props.tutorialSkip();
  }

  tutorialNextPage = () => {
    this.props.tutorialNextPage();
  }

  render() {
    const nextText = this.props.isLast ? '完了' : '次へ';
    const nextAction = this.props.isLast ? this.tutorialSkip : this.tutorialNextPage;
    const visibleSkip = this.props.isLast ? { display: 'none' } : { display: 'inline' };
    const visibleUn = this.props.isLast ? { display: 'inline' } : { display: 'none' };

    return (
      <div className='tutorial-nav'>
        <div className='tutorial-bottombtn'>
          <span role='button' tabIndex='0' onClick={this.tutorialSkip} className='tutorial-navleft tutorial-btn' style={visibleSkip}>終了</span>
          <span className='tutorial-navleft last' style={visibleUn} />
          <span className='tutorial-navtext tutorial-navcenter'>{this.props.navText}</span>
          <span role='button' tabIndex='0' onClick={nextAction} className='tutorial-navright tutorial-btn'>{nextText}</span>
        </div>
        <div className='tutorial-startbtn' >
          <p className='tutorial-btn' role='button' tabIndex='0' onClick={nextAction}>始める</p>
        </div>
      </div>
    );
  }

};
