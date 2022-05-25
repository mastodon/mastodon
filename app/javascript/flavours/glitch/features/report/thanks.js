import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage } from 'react-intl';
import Button from 'flavours/glitch/components/button';
import { connect } from 'react-redux';
import {
  unfollowAccount,
  muteAccount,
  blockAccount,
} from 'flavours/glitch/actions/accounts';

const mapStateToProps = () => ({});

export default @connect(mapStateToProps)
class Thanks extends React.PureComponent {

  static propTypes = {
    submitted: PropTypes.bool,
    onClose: PropTypes.func.isRequired,
    account: ImmutablePropTypes.map.isRequired,
    dispatch: PropTypes.func.isRequired,
  };

  handleCloseClick = () => {
    const { onClose } = this.props;
    onClose();
  };

  handleUnfollowClick = () => {
    const { dispatch, account, onClose } = this.props;
    dispatch(unfollowAccount(account.get('id')));
    onClose();
  };

  handleMuteClick = () => {
    const { dispatch, account, onClose } = this.props;
    dispatch(muteAccount(account.get('id')));
    onClose();
  };

  handleBlockClick = () => {
    const { dispatch, account, onClose } = this.props;
    dispatch(blockAccount(account.get('id')));
    onClose();
  };

  render () {
    const { account, submitted } = this.props;

    return (
      <React.Fragment>
        <h3 className='report-dialog-modal__title'>{submitted ? <FormattedMessage id='report.thanks.title_actionable' defaultMessage="Thanks for reporting, we'll look into this." /> : <FormattedMessage id='report.thanks.title' defaultMessage="Don't want to see this?" />}</h3>
        <p className='report-dialog-modal__lead'>{submitted ? <FormattedMessage id='report.thanks.take_action_actionable' defaultMessage='While we review this, you can take action against @{name}:' values={{ name: account.get('username') }} /> : <FormattedMessage id='report.thanks.take_action' defaultMessage='Here are your options for controlling what you see on Mastodon:' />}</p>

        {account.getIn(['relationship', 'following']) && (
          <React.Fragment>
            <h4 className='report-dialog-modal__subtitle'><FormattedMessage id='report.unfollow' defaultMessage='Unfollow @{name}' values={{ name: account.get('username') }} /></h4>
            <p className='report-dialog-modal__lead'><FormattedMessage id='report.unfollow_explanation' defaultMessage='You are following this account. To not see their posts in your home feed anymore, unfollow them.' /></p>
            <Button secondary onClick={this.handleUnfollowClick}><FormattedMessage id='account.unfollow' defaultMessage='Unfollow' /></Button>
            <hr />
          </React.Fragment>
        )}

        <h4 className='report-dialog-modal__subtitle'><FormattedMessage id='account.mute' defaultMessage='Mute @{name}' values={{ name: account.get('username') }} /></h4>
        <p className='report-dialog-modal__lead'><FormattedMessage id='report.mute_explanation' defaultMessage='You will not see their posts. They can still follow you and see your posts and will not know that they are muted.' /></p>
        <Button secondary onClick={this.handleMuteClick}>{!account.getIn(['relationship', 'muting']) ? <FormattedMessage id='report.mute' defaultMessage='Mute' /> : <FormattedMessage id='account.muted' defaultMessage='Muted' />}</Button>

        <hr />

        <h4 className='report-dialog-modal__subtitle'><FormattedMessage id='account.block' defaultMessage='Block @{name}' values={{ name: account.get('username') }} /></h4>
        <p className='report-dialog-modal__lead'><FormattedMessage id='report.block_explanation' defaultMessage='You will not see their posts. They will not be able to see your posts or follow you. They will be able to tell that they are blocked.' /></p>
        <Button secondary onClick={this.handleBlockClick}>{!account.getIn(['relationship', 'blocking']) ? <FormattedMessage id='report.block' defaultMessage='Block' /> : <FormattedMessage id='account.blocked' defaultMessage='Blocked' />}</Button>

        <div className='flex-spacer' />

        <div className='report-dialog-modal__actions'>
          <Button onClick={this.handleCloseClick}><FormattedMessage id='report.close' defaultMessage='Done' /></Button>
        </div>
      </React.Fragment>
    );
  }

}
