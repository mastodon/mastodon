import React from 'react';
import PropTypes from 'prop-types';
import TutorialContents from './tutorial_contents';

export default class Tutorial extends React.Component {

  static propTypes = {
    visible: PropTypes.bool,
    onClose: PropTypes.func,
  };

  state = {
    page: 1,
    display: 'block',
    totalPage: 4,
  };

  tutorialSkip = () => {
    this.setState({
      opacity: 0,
    });
    setTimeout(() => {
      this.props.onClose();
    }, 500);
  }

  tutorialNextPage = () => {
    this.setState({
      page: this.state.page + 1,
    });
  }

  render() {
    const { visible } = this.props;

    if (!visible) {
      return <div className='tutorial' />;
    }

    document.querySelector('.columns-area').style.overflowX = 'hidden';

    const args = {
      tutorialSkip: this.tutorialSkip,
      tutorialNextPage: this.tutorialNextPage,
      nowPage: this.state.page,
      allPage: 4,
      totalPage: this.state.totalPage,
      numberOfBackNone: 1,
    };

    const tutorialContents = [
      <TutorialContents
        key={1}
        page_number={1}
        page='welcome'
        target='All'
        display_target='none'
        direction='none'
        tutorialPosition={70}
        {...args}
      />,
      <TutorialContents
        key={2}
        page_number={2}
        page='ltl'
        target='Column:localTimeLine'
        display_target='Column:localTimeLine'
        direction='left'
        tutorialPosition={20}
        {...args}
      />,
      <TutorialContents
        key={3}
        page_number={3}
        page='htl'
        target='Column:home'
        display_target='Column:home'
        direction='right'
        tutorialPosition={20}
        {...args}
      />,
      <TutorialContents
        key={4}
        page_number={4}
        page='help'
        target='Menu:help'
        display_target='Menu:help'
        direction='right'
        tutorialPosition={-220}
        {...args}
      />,
      <TutorialContents
        key={5}
        page_number={5}
        page='toot'
        target='Form:toot'
        display_target='Form:toot'
        direction='left'
        tutorialPosition={45}
        {...args}
        isLast
      />,
    ];

    return (
      <div className='tutorial' style={{ opacity: this.state.opacity, display: this.state.display }}>
        {tutorialContents}
        <div className='tutorial-back-top tutorial-back' />
        <div className='tutorial-back-right tutorial-back' />
        <div className='tutorial-back-bottom tutorial-back' />
        <div className='tutorial-back-left tutorial-back' />
      </div>
    );
  }

}
