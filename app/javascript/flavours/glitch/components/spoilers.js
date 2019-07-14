import React from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';

export default
class Spoilers extends React.PureComponent {
  static propTypes = {
    spoilerText: PropTypes.string,
    children: PropTypes.node,
  };

  state = {
    hidden: true,
  }

  handleSpoilerClick = () => {
    this.setState({ hidden: !this.state.hidden });
  }

  render () {
    const { spoilerText, children } = this.props;
    const { hidden } = this.state;

      const toggleText = hidden ?
        <FormattedMessage
          id='status.show_more'
          defaultMessage='Show more'
          key='0'
        /> :
        <FormattedMessage
          id='status.show_less'
          defaultMessage='Show less'
          key='0'
        />;

    return ([
      <p className='spoiler__text'>
        {spoilerText}
        {' '}
        <button tabIndex='0' className='status__content__spoiler-link' onClick={this.handleSpoilerClick}>
          {toggleText}
        </button>
      </p>,
      <div className={`status__content__spoiler ${!hidden ? 'status__content__spoiler--visible' : ''}`}>
        {children}
      </div>
    ]);
  }
}

