import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import { injectIntl, FormattedMessage } from 'react-intl';
import { makeGetAccount } from '../../../selectors';
import Toggle from 'react-toggle';
import Button from '../../../components/button';
import { closeModal } from '../../../actions/modal';
import { blockAccount } from '../../../actions/accounts';
import { initReport } from '../../../actions/reports';
import { toggleHardBlock } from '../../../actions/blocks';


const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = state => ({
    account: getAccount(state, state.getIn(['blocks', 'new', 'account_id'])),
    hardBlock: state.getIn(['blocks', 'new', 'hard_block']),
  });

  return mapStateToProps;
};

const mapDispatchToProps = dispatch => {
  return {
    onConfirm(account, hardBlock) {
      dispatch(blockAccount(account.get('id'), hardBlock));
    },

    onBlockAndReport(account, hardBlock) {
      dispatch(blockAccount(account.get('id'), hardBlock));
      dispatch(initReport(account));
    },

    onToggleHardBlock() {
      dispatch(toggleHardBlock());
    },

    onClose() {
      dispatch(closeModal());
    },
  };
};

export default @connect(makeMapStateToProps, mapDispatchToProps)
@injectIntl
class BlockModal extends React.PureComponent {

  static propTypes = {
    account: PropTypes.object.isRequired,
    hardBlock: PropTypes.bool.isRequired,
    onClose: PropTypes.func.isRequired,
    onBlockAndReport: PropTypes.func.isRequired,
    onConfirm: PropTypes.func.isRequired,
    onToggleHardBlock: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  componentDidMount() {
    this.button.focus();
  }

  handleClick = () => {
    this.props.onClose();
    this.props.onConfirm(this.props.account, this.props.hardBlock);
  }

  handleSecondary = () => {
    this.props.onClose();
    this.props.onBlockAndReport(this.props.account, this.props.hardBlock);
  }

  toggleHardBlock = () => {
    this.props.onToggleHardBlock();
  }

  handleCancel = () => {
    this.props.onClose();
  }

  setRef = (c) => {
    this.button = c;
  }

  render () {
    const { account, hardBlock } = this.props;

    const local = account.get('acct') === account.get('username');
    const following = !!account.getIn(['relationship', 'followed_by']);

    return (
      <div className='modal-root__modal block-modal'>
        <div className='block-modal__container'>
          <p>
            <FormattedMessage
              id='confirmations.block.message'
              defaultMessage='Are you sure you want to block {name}?'
              values={{ name: <strong>@{account.get('acct')}</strong> }}
            />
          </p>
          <p className='block-modal__explanation'>
            <FormattedMessage
              id='confirmations.block.explanation'
              defaultMessage='This will {following, select, true {forcibly remove them from your followers,} false {}} reject their incoming follow request, and hide content and notifications from them or mentioning them.'
              values={{ following }}
            />
          </p>

          <div className='setting-toggle'>
            <Toggle id='block-modal__hard-block-checkbox' checked={hardBlock} onChange={this.toggleHardBlock} />
            <label className='setting-toggle__label' htmlFor='block-modal__hard-block-checkbox'>
              {local ? (
                <FormattedMessage id='block_modal.hard_block.local' defaultMessage='Prevent them from seeing your content when they are logged in (this may let them know they are blocked)' />
              ) : (
                <FormattedMessage id='block_modal.hard_block.remote' defaultMessage='Notify their server and ask it not to show them your content (this may let them know they are blocked)' />
              )}
              {' '}
            </label>
          </div>
        </div>

        <div className='block-modal__action-bar'>
          <Button onClick={this.handleCancel} className='block-modal__cancel-button'>
            <FormattedMessage id='confirmation_modal.cancel' defaultMessage='Cancel' />
          </Button>
          <Button onClick={this.handleSecondary} className='confirmation-modal__secondary-button'>
            <FormattedMessage id='confirmations.block.block_and_report' defaultMessage='Block & Report' />
          </Button>
          <Button onClick={this.handleClick} ref={this.setRef}>
            <FormattedMessage id='confirmations.block.confirm' defaultMessage='Block' />
          </Button>
        </div>
      </div>
    );
  }

}
