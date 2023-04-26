import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';
import { focusCompose } from 'mastodon/actions/compose';
import Column from 'mastodon/features/ui/components/column';
import { Helmet } from 'react-helmet';
import illustration from 'mastodon/../images/elephant_ui_conversation.svg';
import { Link } from 'react-router-dom';
import { me } from 'mastodon/initial_state';
import { makeGetAccount } from 'mastodon/selectors';
import { closeOnboarding } from 'mastodon/actions/onboarding';
import { fetchAccount } from 'mastodon/actions/accounts';
import Follows from './follows';
import Share from './share';
import Step from './components/step';
import ArrowSmallRight from './components/arrow_small_right';
import { FormattedMessage } from 'react-intl';
import { debounce } from 'lodash';

const mapStateToProps = () => {
  const getAccount = makeGetAccount();

  return state => ({
    account: getAccount(state, me),
  });
};

class Onboarding extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object.isRequired,
  };

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    account: ImmutablePropTypes.map,
  };

  state = {
    step: null,
    profileClicked: false,
    shareClicked: false,
  };

  handleClose = () => {
    const { dispatch } = this.props;
    const { router } = this.context;

    dispatch(closeOnboarding());
    router.history.push('/home');
  };

  handleProfileClick = () => {
    this.setState({ profileClicked: true });
  };

  handleFollowClick = () => {
    this.setState({ step: 'follows' });
  };

  handleComposeClick = () => {
    const { dispatch } = this.props;
    const { router } = this.context;

    dispatch(focusCompose(router.history));
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
    const { account } = this.props;
    const { step, shareClicked } = this.state;

    switch(step) {
    case 'follows':
      return <Follows onBack={this.handleBackClick} />;
    case 'share':
      return <Share onBack={this.handleBackClick} />;
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
            <Step onClick={this.handleProfileClick} href='/settings/profile' completed={(!account.get('avatar').endsWith('missing.png')) || (account.get('display_name').length > 0 && account.get('note').length > 0)} icon='address-book-o' label={<FormattedMessage id='onboarding.steps.setup_profile.title' defaultMessage='Customize your profile' />} description={<FormattedMessage id='onboarding.steps.setup_profile.body' defaultMessage='Others are more likely to interact with you with a filled out profile.' />} />
            <Step onClick={this.handleFollowClick} completed={(account.get('following_count') * 1) >= 7} icon='user-plus' label={<FormattedMessage id='onboarding.steps.follow_people.title' defaultMessage='Follow {count, plural, one {one person} other {# people}}' values={{ count: 7 }} />} description={<FormattedMessage id='onboarding.steps.follow_people.body' defaultMessage='You curate your own feed. Lets fill it with interesting people.' />} />
            <Step onClick={this.handleComposeClick} completed={(account.get('statuses_count') * 1) >= 1} icon='pencil-square-o' label={<FormattedMessage id='onboarding.steps.publish_status.title' defaultMessage='Make your first post' />} description={<FormattedMessage id='onboarding.steps.publish_status.body' defaultMessage='Say hello to the world.' />} />
            <Step onClick={this.handleShareClick} completed={shareClicked} icon='copy' label={<FormattedMessage id='onboarding.steps.share_profile.title' defaultMessage='Share your profile' />} description={<FormattedMessage id='onboarding.steps.share_profile.body' defaultMessage='Let your friends know how to find you on Mastodon!' />} />
          </div>

          <p className='onboarding__lead'><FormattedMessage id='onboarding.start.skip' defaultMessage='Want to skip right ahead?' /></p>

          <div className='onboarding__links'>
            <Link to='/explore' className='onboarding__link'>
              <ArrowSmallRight />
              <FormattedMessage id='onboarding.actions.go_to_explore' defaultMessage="See what's trending" />
            </Link>
          </div>

          <div className='onboarding__footer'>
            <button className='link-button' onClick={this.handleClose}><FormattedMessage id='onboarding.actions.close' defaultMessage="Don't show this screen again" /></button>
          </div>
        </div>

        <Helmet>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(Onboarding);
