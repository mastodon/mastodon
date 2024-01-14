import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { injectIntl, defineMessages } from 'react-intl';

import { ReactComponent as PersonIcon } from '@material-symbols/svg-600/outlined/person.svg';

import ColumnHeader from '../../../components/column_header';

const messages = defineMessages({
  profile: { id: 'column_header.profile', defaultMessage: 'Profile' },
});

class ProfileColumnHeader extends PureComponent {

  static propTypes = {
    onClick: PropTypes.func,
    multiColumn: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  render() {
    const { onClick, intl, multiColumn } = this.props;

    return (
      <ColumnHeader
        icon='user-circle'
        iconComponent={PersonIcon}
        title={intl.formatMessage(messages.profile)}
        onClick={onClick}
        showBackButton
        multiColumn={multiColumn}
      />
    );
  }

}

export default injectIntl(ProfileColumnHeader);
