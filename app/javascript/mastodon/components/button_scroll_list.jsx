import PropTypes from 'prop-types';
import React, { Component } from 'react';

import ChevronLeftIcon from '@/material-icons/400-24px/chevron_left.svg?react';
import ChevronRightIcon from '@/material-icons/400-24px/chevron_right.svg?react';
import { Icon } from 'mastodon/components/icon';

class ButtonScrollList extends Component {
  static propTypes = {
    children: PropTypes.node.isRequired,
  };

  constructor(props) {
    super(props);
    this.scrollRef = React.createRef();
    this.slide = 0;
    this.childrenLength = React.Children.count(props.children);
  }

  componentDidMount() {
    setTimeout(() => {
      if (this.scrollRef && this.scrollRef.current) {
        const container = this.scrollRef.current;
        container.scrollTo({ left: 0, behavior: 'auto' });
        this.slide = 0;
      }
    }, 500);
  }

  scrollLeft = () => {
    if (this.scrollRef && this.scrollRef.current) {
      this.scrollRef.current.scrollBy({ left: -200, behavior: 'smooth' });
      this.slide = Math.max(0, this.slide - 1);
    }
  };

  scrollRight = () => {
    if (this.scrollRef && this.scrollRef.current) {
      const { children } = this.props;
      const container = this.scrollRef.current;
      const maxScrollLeft = container.scrollWidth - container.clientWidth;

      if (container.scrollLeft < maxScrollLeft) {
        container.scrollBy({ left: 200, behavior: 'smooth' });
        this.slide = Math.min(
          React.Children.count(children) - 1,
          this.slide + 1,
        );
      } else {
      }
    }
  };

  render() {
    const { children } = this.props;

    if (React.Children.count(children) === 0) {
      return null;
    }

    return (
      <div className='button-scroll-list-container'>
        <button
          className='icon-button column-header__setting-btn'
          aria-label='Scroll left'
          onClick={this.scrollLeft}
        >
          <Icon id='chevron-left' icon={ChevronLeftIcon} />
        </button>
        <div className='button-scroll-list' ref={this.scrollRef}>
          {React.Children.map(children, (child, index) => (
            <div key={index}>{child}</div>
          ))}
        </div>
        <button
          className='icon-button column-header__setting-btn'
          aria-label='Scroll right'
          onClick={this.scrollRight}
        >
          <Icon id='chevron-right' icon={ChevronRightIcon} />
        </button>
      </div>
    );
  }
}

export default ButtonScrollList;
