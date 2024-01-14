import PropTypes from 'prop-types';
import React from 'react';

import { FormattedMessage, injectIntl, defineMessages } from 'react-intl';

import { Helmet } from 'react-helmet';
import { Link, withRouter } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import { ReactComponent as AccountCircleIcon } from '@material-symbols/svg-600/outlined/account_circle.svg';
import { ReactComponent as ArrowRightAltIcon } from '@material-symbols/svg-600/outlined/arrow_right_alt.svg';
import { ReactComponent as ContentCopyIcon } from '@material-symbols/svg-600/outlined/content_copy.svg';
import { ReactComponent as EditNoteIcon } from '@material-symbols/svg-600/outlined/edit_note.svg';
import { ReactComponent as PersonAddIcon } from '@material-symbols/svg-600/outlined/person_add.svg';
import { debounce } from 'lodash';

import { fetchAccount } from 'flavours/glitch/actions/accounts';
import { focusCompose } from 'flavours/glitch/actions/compose';
import { closeOnboarding } from 'flavours/glitch/actions/onboarding';
import { Icon }  from 'flavours/glitch/components/icon';
import Column from 'flavours/glitch/features/ui/components/column';
import { me } from 'flavours/glitch/initial_state';
import { makeGetAccount } from 'flavours/glitch/selectors';
import { assetHost } from 'flavours/glitch/utils/config';
import { WithRouterPropTypes } from 'flavours/glitch/utils/react_router';
import illustration from 'mastodon/../images/elephant_ui_conversation.svg';

import Step from './components/step';
import Follows from './follows';
import Share from './share';

const messages = defineMessages({
  template: { id: 'onboarding.compose.template', defaultMessage: 'Hello #Mastodon!' },
});

const mapStateToProps = () => {
  const getAccount = makeGetAccount();

  return state => ({
    account: getAccount(state, me),
  });
};

class Onboarding extends ImmutablePureComponent {
  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    account: ImmutablePropTypes.record,
    multiColumn: PropTypes.bool,
    ...WithRouterPropTypes,
  };

  state = {
    step: null,
    profileClicked: false,
    shareClicked: false,
  };

  handleClose = () => {
    const { dispatch, history } = this.props;

    dispatch(closeOnboarding());
    history.push('/home');
  };

  handleProfileClick = () => {
    this.setState({ profileClicked: true });
  };

  handleFollowClick = () => {
    this.setState({ step: 'follows' });
  };

  handleComposeClick = () => {
    const { dispatch, intl, history } = this.props;

    dispatch(focusCompose(history, intl.formatMessage(messages.template)));
  };

  handleShareClick = () => {
    this.setState({ step: 'share', shareClicked: true });
  };

  handleBackClick = () => {
    this.setState({ step: null });
  };

  handleWindowFocus = debounce(() => {
    const { dispatch, account } = this.props;
    dispatch(fetchAccount(account.get('id')));
  }, 1000, { trailing: true });

  componentDidMount () {
    window.addEventListener('focus', this.handleWindowFocus, false);
  }

  componentWillUnmount () {
    window.removeEventListener('focus', this.handleWindowFocus);
  }

  render () {
    const { account, multiColumn } = this.props;
    const { step, shareClicked } = this.state;

    switch(step) {
    case 'follows':
      return <Follows onBack={this.handleBackClick} multiColumn={multiColumn} />;
    case 'share':
      return <Share onBack={this.handleBackClick} multiColumn={multiColumn} />;
    }

    return (
      <Column>
        <div className='scrollable privacy-policy'>
          <div className='column-title'>
            <img src={illustration} alt='' className='onboarding__illustration' />
            <h3><FormattedMessage id='onboarding.start.title' defaultMessage="You've made it!" /></h3>
            <p><FormattedMessage id='onboarding.start.lead' defaultMessage="Your new Mastodon account is ready to go. Here's how you can make the most of it:" /></p>
          </div>

          <div className='onboarding__steps'>
            <Step onClick={this.handleProfileClick} href='/settings/profile' completed={(!account.get('avatar').endsWith('missing.png')) || (account.get('display_name').length > 0 && account.get('note').length > 0)} icon='address-book-o' iconComponent={AccountCircleIcon} label={<FormattedMessage id='onboarding.steps.setup_profile.title' defaultMessage='Customize your profile' />} description={<FormattedMessage id='onboarding.steps.setup_profile.body' defaultMessage='Others are more likely to interact with you with a filled out profile.' />} />
            <Step onClick={this.handleFollowClick} completed={(account.get('following_count') * 1) >= 7} icon='user-plus' iconComponent={PersonAddIcon} label={<FormattedMessage id='onboarding.steps.follow_people.title' defaultMessage='Find at least {count, plural, one {one person} other {# people}} to follow' values={{ count: 7 }} />} description={<FormattedMessage id='onboarding.steps.follow_people.body' defaultMessage="You curate your own home feed. Let's fill it with interesting people." />} />
            <Step onClick={this.handleComposeClick} completed={(account.get('statuses_count') * 1) >= 1} icon='pencil-square-o' iconComponent={EditNoteIcon} label={<FormattedMessage id='onboarding.steps.publish_status.title' defaultMessage='Make your first post' />} description={<FormattedMessage id='onboarding.steps.publish_status.body' defaultMessage='Say hello to the world.' values={{ emoji: <img className='emojione' alt='🐘' src={`${assetHost}/emoji/1f418.svg`} /> }} />} />
            <Step onClick={this.handleShareClick} completed={shareClicked} icon='copy' iconComponent={ContentCopyIcon} label={<FormattedMessage id='onboarding.steps.share_profile.title' defaultMessage='Share your profile' />} description={<FormattedMessage id='onboarding.steps.share_profile.body' defaultMessage='Let your friends know how to find you on Mastodon!' />} />
          </div>

          <p className='onboarding__lead'><FormattedMessage id='onboarding.start.skip' defaultMessage="Don't need help getting started?" /></p>

          <div className='onboarding__links'>
            <Link to='/explore' className='onboarding__link'>
              <FormattedMessage id='onboarding.actions.go_to_explore' defaultMessage='Take me to trending' />
              <Icon icon={ArrowRightAltIcon} />
            </Link>

            <Link to='/home' className='onboarding__link'>
              <FormattedMessage id='onboarding.actions.go_to_home' defaultMessage='Take me to my home feed' />
              <Icon icon={ArrowRightAltIcon} />
            </Link>
          </div>
        </div>

        <Helmet>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}

export default withRouter(connect(mapStateToProps)(injectIntl(Onboarding)));
