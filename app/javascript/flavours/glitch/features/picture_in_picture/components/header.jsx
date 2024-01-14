import PropTypes from 'prop-types';

import { defineMessages, injectIntl } from 'react-intl';

import { Link } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import { ReactComponent as CloseIcon } from '@material-symbols/svg-600/outlined/close.svg';

import { Avatar } from 'flavours/glitch/components/avatar';
import { DisplayName } from 'flavours/glitch/components/display_name';
import { IconButton } from 'flavours/glitch/components/icon_button';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
});

const mapStateToProps = (state, { accountId }) => ({
  account: state.getIn(['accounts', accountId]),
});

class Header extends ImmutablePureComponent {

  static propTypes = {
    accountId: PropTypes.string.isRequired,
    statusId: PropTypes.string.isRequired,
    account: ImmutablePropTypes.record.isRequired,
    onClose: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { account, statusId, onClose, intl } = this.props;

    return (
      <div className='picture-in-picture__header'>
        <Link to={`/@${account.get('acct')}/${statusId}`} className='picture-in-picture__header__account'>
          <Avatar account={account} size={36} />
          <DisplayName account={account} />
        </Link>

        <IconButton icon='times' iconComponent={CloseIcon} onClick={onClose} title={intl.formatMessage(messages.close)} />
      </div>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(Header));
