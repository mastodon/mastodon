import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

export default class LoadMore extends PureComponent {

  static propTypes = {
    onClick: PropTypes.func,
    disabled: PropTypes.bool,
    visible: PropTypes.bool,
  };

  static defaultProps = {
    visible: true,
  };

  render() {
    const { disabled, visible } = this.props;

    return (
      <button type='button' className='load-more' disabled={disabled || !visible} style={{ visibility: visible ? 'visible' : 'hidden' }} onClick={this.props.onClick}>
        <FormattedMessage id='status.load_more' defaultMessage='Load more' />
      </button>
    );
  }

}
