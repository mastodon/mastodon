import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

export default class LoadPending extends PureComponent {

  static propTypes = {
    onClick: PropTypes.func,
    count: PropTypes.number,
  };

  render() {
    const { count } = this.props;

    return (
      <button className='load-more load-gap' onClick={this.props.onClick}>
        <FormattedMessage id='load_pending' defaultMessage='{count, plural, one {# new item} other {# new items}}' values={{ count }} />
      </button>
    );
  }

}
