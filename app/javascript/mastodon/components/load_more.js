import React from 'react';
import { FormattedMessage } from 'react-intl';
import PropTypes from 'prop-types';

export default class LoadMore extends React.PureComponent {

  static propTypes = {
    onClick: PropTypes.func,
  }

  render() {
    return (
      <button className='load-more' onClick={this.props.onClick}>
        <FormattedMessage id='status.load_more' defaultMessage='Load more' />
      </button>
    );
  }

}
