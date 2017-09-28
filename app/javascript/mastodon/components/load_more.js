import React from 'react';
import { FormattedMessage } from 'react-intl';
import PropTypes from 'prop-types';

export default class LoadMore extends React.PureComponent {

  static propTypes = {
    onClick: PropTypes.func,
    visible: PropTypes.bool,
  }

  static defaultProps = {
    visible: true,
  }

  render() {
    const { visible } = this.props;

    return (
      <button className='load-more' disabled={!visible} style={{ visibility: visible ? 'visible' : 'hidden' }} onClick={this.props.onClick}>
        <FormattedMessage id='status.load_more' defaultMessage='Load more' />
      </button>
    );
  }

}
