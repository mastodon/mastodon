import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { makeGetAccount } from '../../../selectors';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Avatar from '../../../components/avatar';
import DisplayName from '../../../components/display_name';
import IconButton from '../../../components/icon_button';
import { defineMessages, injectIntl } from 'react-intl';
import { removeFromListEditor } from '../../../actions/lists';

const messages = defineMessages({
  remove: { id: 'lists.account.remove', defaultMessage: 'Remove from list' },
});

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = (state, { accountId }) => ({
    account: getAccount(state, accountId),
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch, { accountId }) => ({
  onRemove: () => dispatch(removeFromListEditor(accountId)),
});

@connect(makeMapStateToProps, mapDispatchToProps)
@injectIntl
export default class Account extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    intl: PropTypes.object.isRequired,
    onRemove: PropTypes.func.isRequired,
  };

  render () {
    const { account, intl, onRemove } = this.props;

    return (
      <div className='account'>
        <div className='account__wrapper'>
          <div className='account__display-name'>
            <div className='account__avatar-wrapper'><Avatar account={account} size={36} /></div>
            <DisplayName account={account} />
          </div>

          <div className='account__relationship'>
            <IconButton icon='times' title={intl.formatMessage(messages.remove)} onClick={onRemove} />
          </div>
        </div>
      </div>
    );
  }

}
