import React from 'react';
import PropTypes from 'prop-types';
import { FormattedNumber } from 'react-intl';
import TransitionMotion from 'react-motion/lib/TransitionMotion';
import spring from 'react-motion/lib/spring';
import { reduceMotion } from 'flavours/glitch/util/initial_state';

export default class AnimatedNumber extends React.PureComponent {

  static propTypes = {
    value: PropTypes.number.isRequired,
  };

  willEnter () {
    return { y: -1 };
  }

  willLeave () {
    return { y: spring(1, { damping: 35, stiffness: 400 }) };
  }

  render () {
    const { value } = this.props;

    if (reduceMotion) {
      return <FormattedNumber value={value} />;
    }

    const styles = [{
      key: value,
      style: { y: spring(0, { damping: 35, stiffness: 400 }) },
    }];

    return (
      <TransitionMotion styles={styles} willEnter={this.willEnter} willLeave={this.willLeave}>
        {items => (
          <span className='animated-number'>
            {items.map(({ key, style }) => (
              <span key={key} style={{ position: style.y > 0 ? 'absolute' : 'static', transform: `translateY(${style.y * 100}%)` }}><FormattedNumber value={key} /></span>
            ))}
          </span>
        )}
      </TransitionMotion>
    );
  }

}
