import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage } from 'react-intl';
import Button from 'mastodon/components/button';
import { connect } from 'react-redux';
import { initMuteModal } from 'mastodon/actions/mutes';
import { blockAccount } from 'mastodon/actions/accounts';

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

  handleMuteClick = () => {
    const { dispatch, account } = this.props;
    dispatch(initMuteModal(account));
  };

  handleBlockClick = () => {
    const { dispatch, account } = this.props;
    dispatch(blockAccount(account.get('id')));
  };

  render () {
    const { account, submitted } = this.props;

    const options = [];

    if (!account.getIn(['relationship', 'muting'])) {
      options.push((
        <React.Fragment key='mute'>
          <h4 className='report-dialog-modal__subtitle'><FormattedMessage id='account.mute' defaultMessage='Mute @{name}' values={{ name: account.get('username') }} /></h4>
          <p className='report-dialog-modal__lead'><FormattedMessage id='report.mute_explanation' defaultMessage='You will not see their posts. They can still follow you and see your posts and will not know that they are muted.' /></p>
          <Button secondary onClick={this.handleMuteClick}><FormattedMessage id='report.mute' defaultMessage='Mute' /></Button>
        </React.Fragment>
      ));
    }

    if (!account.getIn(['relationship', 'blocking'])) {
      options.push((
        <React.Fragment key='block'>
          <h4 className='report-dialog-modal__subtitle'><FormattedMessage id='account.block' defaultMessage='Block @{name}' values={{ name: account.get('username') }} /></h4>
          <p className='report-dialog-modal__lead'><FormattedMessage id='report.block_explanation' defaultMessage='You will not see their posts. They will not be able to see your posts or follow you. They will be able to tell that they are blocked.' /></p>
          <Button secondary onClick={this.handleBlockClick}><FormattedMessage id='report.block' defaultMessage='Block' /></Button>
        </React.Fragment>
      ));
    }

    return (
      <React.Fragment>
        <h3 className='report-dialog-modal__title'>{submitted ? <FormattedMessage id='report.thanks.title_actionable' defaultMessage="Thanks for reporting, we'll look into this." /> : <FormattedMessage id='report.thanks.title' defaultMessage='Thank you for reporting.' />}</h3>
        <p className='report-dialog-modal__lead'>{submitted ? <FormattedMessage id='report.thanks.take_action_actionable' defaultMessage='While we review this, you can take action against @{name}:' values={{ name: account.get('username') }} /> : <FormattedMessage id='report.thanks.take_action' defaultMessage='Here are your options for controlling what you see:' />}</p>

        {options.reduce((prev, curr) => [prev, <hr />, curr])}

        <div className='flex-spacer' />

        <div className='report-dialog-modal__actions'>
          <Button onClick={this.handleCloseClick}><FormattedMessage id='report.close' defaultMessage='Done' /></Button>
        </div>
      </React.Fragment>
    );
  }

}
