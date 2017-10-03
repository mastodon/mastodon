import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import TutorialNav from './tutorial_nav';

import getTargetPosigion from '../utils/get_target_position';
import { scrollLeft, scrollRight } from '../utils/scroll';

const PageOne = ({ page }) => {

  switch (page) {
  case 'welcome':
    return (
      <div className='tutorial-back-none'>
        <p className='tutorial-title'>ようこそアイマストドンへ</p>
        <div className='tutorial-image imastodon-logo' />
        <p className='tutorial-paragraph'>アイマストドンはアイドルマスターシリーズに興味がある<br />人のための非公式マストドンです。</p>
        <p className='tutorial-paragraph'>その機能を実際に触りながら体験して見ましょう！</p>
        <p className='tutorial-footer'>MastodonはOSSです。<br />バグ報告や機能要望あるいは貢献を <a target='_blank' href='https://github.com/tootsuite/mastodon'>こちら</a> から行なえます。</p>
      </div>
    );
  case 'ltl':
    return (
      <div className='tutorial-back-exist'>
        <p className='tutorial-title'>ローカルタイムライン<i className='fa fa-fw fa-users' /></p>
        <p className='tutorial-paragraph'>ここには、公開範囲が「公開」に設定されているアイマストドン内の投稿（トゥート）が流れてきます。</p>
        <p className='tutorial-paragraph'>眺めて楽しむのも良いですし、時には会話に参加してみましょう！</p>
      </div>
    );
  case 'htl':
    return (
      <div className='tutorial-back-exist'>
        <p className='tutorial-title'>ホームタイムライン<i className='fa fa-fw fa-home' /></p>
        <p className='tutorial-paragraph'>ここにはあなたがフォローしている人の投稿（トゥート）が、公開範囲が「非公開」なものも含め流れてきます。</p>
        <p className='tutorial-paragraph'>ローカルタイムラインで気になる人を見つけたらフォローしてみましょう！</p>
      </div>
    );
  case 'help':
    return (
      <div className='tutorial-back-exist'>
        <p className='tutorial-title'>ヘルプ<i className='fa fa-fw fa-question' /></p>
        <p className='tutorial-paragraph'>困った時はここから使い方を読むことができます。</p>
        <p className='tutorial-paragraph'>それでもわからないことがあるときには @imastodon へ聞いてみてください。</p>
      </div>
    );
  case 'toot':
    return (
      <div className='tutorial-back-exist'>
        <p className='tutorial-title'>トゥート<i className='fa fa-fw fa-pencil' /></p>
        <p className='tutorial-paragraph'>あなたも実際にトゥートしてみましょう！</p>
        <p className='tutorial-paragraph'>みんなが歓迎してくれるかもしれません！</p>
      </div>
    );
  default:
    return (
      <div className='tutorial-back-exist'>
        <p className='tutorial-title'>エラー</p>
        <p className='tutorial-paragraph'>存在しないページです。</p>
      </div>
    );
  }
};

PageOne.propTypes = {
  page: PropTypes.string,
};

const bottomLength = 30;
const balloonHeight = 40;

const refs = [];
const targets = [];
const directions = [];
const displayTargets = [];
const tutorialPositions = [];

const adjustPosition = (contents, targetPosition, direction, balloonPosition) => {
  let position = {};
  position.position = 'fixed';

  switch (direction) {
  case 'top':
    position = {
      top: targetPosition.bottom + 40 + 'px',
      bottom: '',
      left: (targetPosition.left + targetPosition.width * balloonPosition / 100) - 230 + 'px',
      right: '',
    };
    break;
  case 'left':
    position = {
      top: (targetPosition.top + targetPosition.height * balloonPosition / 100) + 'px',
      bottom: '',
      left: targetPosition.right + 50 + 'px',
      right: '',
    };
    break;
  case 'right':
    position = {
      top: (targetPosition.top + targetPosition.height * balloonPosition / 100) + 'px',
      bottom: '',
      left: targetPosition.left - 460 + 'px',
      right: '',
    };
    break;
  }

  Object.assign(contents.style, position);
};

const adjustBackSizePosition = (targetPosition) => {
  let isColumn = targetPosition.height > document.body.clientHeight - 50;
  // top
  document.querySelector('.tutorial-back-top').style.width = targetPosition.width + 'px';
  document.querySelector('.tutorial-back-top').style.height = targetPosition.top + 'px';
  document.querySelector('.tutorial-back-top').style.top = 0;
  document.querySelector('.tutorial-back-top').style.left = targetPosition.left + 'px';

  // right
  document.querySelector('.tutorial-back-right').style.width = window.parent.screen.width + 'px';
  document.querySelector('.tutorial-back-right').style.height = window.parent.screen.height + 'px';
  document.querySelector('.tutorial-back-right').style.top = 0;
  document.querySelector('.tutorial-back-right').style.left = (targetPosition.left + targetPosition.width) + 'px';

  // bottom
  document.querySelector('.tutorial-back-bottom').style.width = targetPosition.width + 'px';
  document.querySelector('.tutorial-back-bottom').style.height = isColumn ? 0 : window.parent.screen.height + 'px';
  document.querySelector('.tutorial-back-bottom').style.top = targetPosition.bottom + 'px';
  document.querySelector('.tutorial-back-bottom').style.left = targetPosition.left + 'px';

  // left
  document.querySelector('.tutorial-back-left').style.width = targetPosition.left + 'px';
  document.querySelector('.tutorial-back-left').style.height = window.parent.screen.height + 'px';
  document.querySelector('.tutorial-back-left').style.top = 0;
  document.querySelector('.tutorial-back-left').style.right = targetPosition.left + 'px';
};

const adjustWindowPosition = (target, newProp) => {
  const columnsAreaLeft = document.querySelector('.columns-area').scrollLeft;
  const columnsAreaRight = document.querySelector('.columns-area').getBoundingClientRect().right;
  const balloonInfo = document.querySelectorAll('.tutorial-contents')[newProp.nowPage - 1].getBoundingClientRect();
  const balloonLeft = balloonInfo.left;
  const balloonRight = balloonInfo.right + columnsAreaLeft;
  const targetInfo = getTargetPosigion(target);
  const targetLeft = targetInfo.left;
  const targetRight = targetInfo.right + columnsAreaLeft;

  const rightShortage = Math.max((balloonRight - columnsAreaRight), (targetRight - columnsAreaRight), 0);
  const leftShortage = Math.max((columnsAreaLeft - balloonLeft), (columnsAreaLeft - targetLeft), 0);

  if (rightShortage > 0) {
    scrollRight(rightShortage + 10);
  } else if (leftShortage > 0) {
    scrollLeft(leftShortage + 10);
  }

  setTimeout(() => {
    try {
      adjustPosition(refs[newProp.nowPage - 1], getTargetPosigion(targets[newProp.nowPage - 1]), directions[newProp.nowPage - 1], tutorialPositions[newProp.nowPage - 1]);
    } catch (e) { }
  }, 600);
  setTimeout(() => {
    try {
      adjustBackSizePosition(getTargetPosigion(displayTargets[newProp.nowPage - 1]));
    } catch (e) { }
  }, 600);
};


export default class TutorialContents extends React.Component {

  static propTypes = {
    page: PropTypes.string.isRequired,
    tutorialSkip: PropTypes.func.isRequired,
    tutorialNextPage: PropTypes.func.isRequired,
    target: PropTypes.string.isRequired,
    display_target: PropTypes.string.isRequired,
    tutorialPosition: PropTypes.number.isRequired,
    page_number: PropTypes.number.isRequired,
    direction: PropTypes.string,
    nowPage: PropTypes.number.isRequired,
    totalPage: PropTypes.number.isRequired,
    isLast: PropTypes.bool,
    numberOfBackNone: PropTypes.number.isRequired,
  };

  state = {
    zIndex: -1,
    opacity: 0,
  }

  tutorialSkip = () => {
    this.props.tutorialSkip();
  }

  tutorialNextPage = () => {
    this.props.tutorialNextPage();
  }

  followingTutorialBack = () => {
    adjustBackSizePosition(getTargetPosigion(displayTargets[this.props.nowPage - 1]));
  }

  componentDidMount() {
    refs.push(ReactDOM.findDOMNode(this.tutorialContents));
    targets.push(this.props.target);
    directions.push(this.props.direction);
    displayTargets.push(this.props.display_target);
    tutorialPositions.push(this.props.tutorialPosition);

    window.onload = () => {
      ['.button--block', '.emojione', '.text-icon-button', '.privacy-dropdown', '.compose-form__buttons'].forEach(query => {
        document.querySelector(query).addEventListener('click', function () {
          document.querySelector('.autosuggest-textarea__textarea').placeholder = '今なにしてる？';
          this.props.tutorialSkip();
        }.bind(this), false);
      });
      document.querySelector('.autosuggest-textarea__textarea').placeholder = '初トゥート！';

      this.followingTutorialBack();
    };
    for (let i = 0; i < 4; i++) {
      document.querySelectorAll('.tutorial-back')[i].style.transition = '0.3s';
    }
  }

  PageSwitch = (newProp) => {
    if (newProp.page_number === newProp.nowPage) {
      this.setState({
        zIndex: 20,
        opacity: 1,
      });
    } else {
      this.setState({
        zIndex: -1,
        opacity: 0,
      });
    }
  }

  FirstOpacityChange = () => {
    this.setState({
      zIndex: 20,
      opacity: 1,
    });
  }

  DisplayFirstPage = () => {
    if (this.props.page_number === 1) {
      setTimeout(this.FirstOpacityChange, 1000);
    }
  }

  componentWillMount = () => {
    this.DisplayFirstPage();
  }
  componentWillReceiveProps = (newProp) => {
    this.PageSwitch(newProp);
    adjustBackSizePosition(getTargetPosigion(displayTargets[newProp.nowPage - 1]));
    adjustPosition(refs[newProp.nowPage - 1], getTargetPosigion(targets[newProp.nowPage - 1]), directions[newProp.nowPage - 1], tutorialPositions[newProp.nowPage - 1]);
    adjustWindowPosition(displayTargets[newProp.nowPage - 1], newProp);
  }

  render() {
    let balloonStylePosition = (direction) => {
      switch (direction) {
      case 'right':
        return {
          display: 'block',
          right: '-50px',
          top: '50%',
          border: (bottomLength / 2) + 'px solid transparent',
          borderLeft: balloonHeight + 'px solid #D9E1E8',
        };
      case 'left':
        return {
          display: 'block',
          left: '-50px',
          bottom: '50%',
          border: (bottomLength / 2) + 'px solid transparent',
          borderRight: balloonHeight + 'px solid #D9E1E8',
        };
      case 'top':
        return {
          display: 'block',
          top: '-50px',
          left: (230 - bottomLength) + 'px',
          border: (bottomLength / 2) + 'px solid transparent',
          borderBottom: balloonHeight + 'px solid #D9E1E8',
        };
      default:
        return {
          display: 'none',
        };
      }
    };

    const constantArgumentsForNavigation = {
      tutorialSkip: this.tutorialSkip,
      tutorialNextPage: this.tutorialNextPage,
      navText: (this.props.page_number - this.props.numberOfBackNone) + '/' + this.props.totalPage,
      isLast: this.props.isLast,
    };

    const tutorialContentsRef = (c) => {
      this.tutorialContents = c;
    };

    return (
      <div className='tutorial-box'>
        <div className={`tutorial-contents ${this.props.direction}`} style={{ opacity: this.state.opacity, zIndex: this.state.zIndex }} ref={tutorialContentsRef}>
          <div className='page-one'>
            <PageOne page={this.props.page} />
            <TutorialNav {...constantArgumentsForNavigation} />
          </div>
          <div style={balloonStylePosition(this.props.direction)} className='tutorial-balloon' />
        </div>
      </div>
    );
  }

}
