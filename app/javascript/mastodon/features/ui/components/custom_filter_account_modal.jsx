import PropTypes from 'prop-types';

import ImmutablePureComponent from 'react-immutable-pure-component';

import CustomFilterModal from 'mastodon/features/custom_filters_modal';
import { CustomFilterTypes } from 'mastodon/features/custom_filters_modal/custom_filter_types';

class CustomFilterAccountModal extends ImmutablePureComponent {

  static propTypes = {
    accountId: PropTypes.string.isRequired,
    contextType: PropTypes.string,
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  render () {
    return (
      <CustomFilterModal {...this.props} filterType={CustomFilterTypes.Account} />
    );
  }
}

export default CustomFilterAccountModal;
