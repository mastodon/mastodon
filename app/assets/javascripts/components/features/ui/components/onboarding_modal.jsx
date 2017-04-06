import { connect } from 'react-redux';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import Permalink from '../../../components/permalink';

const PageOne = ({ acct, domain }) => (
  <div className='onboarding-modal__page onboarding-modal__page-one'>
    <h1><FormattedMessage id='onboarding.page_one.welcome' defaultMessage='Welcome to Mastodon!' /></h1>
    <p><FormattedMessage id='onboarding.page_one.federation' defaultMessage='Mastodon is a decentralized federation of {instances} linking up and forming one larger social network.' values={{ instances: <a href='https://instances.mastodon.xyz' target='_blank' rel='noopener'><FormattedMessage id='onboarding.page_one.different_instances' defaultMessage='different server instances' /></a> }} /></p>
    <p><FormattedMessage id='onboarding.page_one.handle' defaultMessage='You are on {domain}, your full handle is {handle}' values={{ domain: <strong>{domain}</strong>, handle: <strong>@{acct}@{domain}</strong> }}/></p>
  </div>
);

const PageTwo => (
  <div className='onboarding-modal__page onboarding-modal__page-two'>
    <img class="onboarding-modal__image onboard-compose" src="/app/assets/images/onboard-compose.jpg">
    <p><FormattedMessage id='onboarding.page_two.compose' defaultMessage='Write posts from the compose column. You can add content warnings, upload images, and change privacy settings with the icons below.' /></p>
  </div>
);


const PageThree => (
  <div className='onboarding-modal__page onboarding-modal__page-three'>
    <img class="onboarding-modal__image onboard-compose" src="/app/assets/images/onboard-search.jpg">
    <p><FormattedMessage id='onboarding.page_three.search' defaultMessage='Use the search bar to find users and look at hashtags, such as #MastoArt and #Introductions.' /></p>
	<p><FormattedMessage id='onboarding.page_three.profile' defaultMessage='Click "Edit Profile" to change your avatar, bio, and display name.' /></p>
  </div>
);

const PageFour => (
  <div className='onboarding-modal__page onboarding-modal__page-four'>
    <img class="onboarding-modal__image onboard-column" src="/app/assets/images/onboard-home.jpg">
	<p><FormattedMessage id='onboarding.page_four.home' defaultMessage='The Home Timeline shows posts from users you follow.'/></p>
	<img class="onboarding-modal__image onboard-column" src="/app/assets/images/onboard-notifications.jpg">
	<p><FormattedMessage id='onboarding.page_four.notifications' defaultMessage='The Notifications Column shows when a user boosts, favorites, or replies to your posts; and when you have a new follower.' /></p>
	<p><FormattedMessage id='onboarding.page_four.filter' defaultMessage='Each column can be customized using the settings menu in the top right.' /></p> <img class="onboarding-modal__image onboard-sliders" src="/app/assets/images/onboard-sliders.jpg">
  </div>
);

const PageFive => (
  <div className='onboarding-modal__page onboarding-modal__page-five'>
    <img class="onboarding-modal__image onboard-column" src="/app/assets/images/onboard-getting-started.jpg">
	<p><FormattedMessage id='onboarding.page_five.getting-started' defaultMessage='The Getting Started Column changes based on your needs.'/></p>
	<img class="onboarding-modal__image onboard-column" src="/app/assets/images/onboard-local-timeline.jpg">
	<p><FormattedMessage id='onboarding.page_five.local-timeline' defaultMessage='The Local Timeline shows public posts from every user on your instance.' /></p>
	<img class="onboarding-modal__image onboard-column" src="/app/assets/images/onboard-federated-timeline.jpg">
	<p><FormattedMessage id='onboarding.page_five.federated-timeline' defaultMessage='The Federated Timeline shows public posts from the whole known network of instances.' /></p>
	<p><FormattedMessage id='onboarding.page_five.public' defaultMessage='These are the Public Timelines, a great way to find people to follow.' /></p>
  </div>
);

const PageSix = ({ admin }) => (
  <div className='onboarding-modal__page onboarding-modal__page-six'>
    <p>
      <FormattedMessage id='onboarding.page_six.admin' defaultMessage="Your instance's admin is {admin}." values={{ admin: <Permalink href={admin.get('url')} to={`/accounts/${admin.get('id')}`}>@{admin.get('acct')}</Permalink> }} />
      <br />
      <FormattedMessage id='onboarding.page_six.read_guidelines' defaultMessage='Please read the {guidelines} of your instance.' values={{ guidelines: <a href='/about/more' target='_blank'><FormattedMessage id='onboarding.page_six.guidelines' defaultMessage='community guidelines' /></a> }}/>
    </p>
    <p><FormattedMessage id='onboarding.page_six.read_guidelines' defaultMessage='Mastodon is free open-source software. You can report bugs, request features, or contribute to the code on {github}.' values={{ github: <a href='https://github.com/tootsuite/mastodon' target='_blank' rel='noopener'>GitHub</a> }} /></p>
    <p><FormattedMessage id='onboarding.page_six.apps_available' defaultMessage='There are {apps} available for iOS and Android.' values={{ apps: <a href='https://github.com/tootsuite/mastodon/blob/master/docs/Using-Mastodon/Apps.md' target='_blank' rel='noopener'><FormattedMessage id='onboarding.page_six.various_app' defaultMessage='mobile apps' /></a> }} /></p>
    <p><strong><FormattedMessage id='onboarding.page_six.have_fun' defaultMessage='Bon Appetoot!' /></strong></p>
  </div>
);

const mapStateToProps = state => ({
  me: state.getIn(['accounts', state.getIn(['meta', 'me'])]),
  admin: state.getIn(['accounts', state.getIn(['meta', 'admin'])]),
  domain: state.getIn(['meta', 'domain'])
});

const OnboardingModal = React.createClass({

  propTypes: {
    onClose: React.PropTypes.func.isRequired,
    intl: React.PropTypes.object.isRequired,
    me: ImmutablePropTypes.map.isRequired,
    domain: React.PropTypes.string.isRequired,
    admin: ImmutablePropTypes.map
  },

  getInitialState () {
    return {
      currentIndex: 0
    };
  },

  mixins: [PureRenderMixin],

  handleSkip (e) {
    e.preventDefault();
    this.props.onClose();
  },

  handleDot (i, e) {
    e.preventDefault();
    this.setState({ currentIndex: i });
  },

  handleNext (maxNum, e) {
    e.preventDefault();

    if (this.state.currentIndex < maxNum - 1) {
      this.setState({ currentIndex: this.state.currentIndex + 1 });
    } else {
      this.props.onClose();
    }
  },

  render () {
    const { me, admin, domain } = this.props;

    const pages = [
      <PageOne acct={me.get('acct')} domain={domain} />,
      <PageSix admin={admin} />
    ];

    const { currentIndex } = this.state;
    const hasMore = currentIndex < pages.length - 1;

    let nextOrDoneBtn;

    if(hasMore) {
      nextOrDoneBtn = <a href='#' onClick={this.handleNext.bind(null, pages.length)} className='onboarding-modal__nav onboarding-modal__next'><FormattedMessage id='onboarding.next' defaultMessage='Next' /></a>;
    } else {
      nextOrDoneBtn = <a href='#' onClick={this.handleNext.bind(null, pages.length)} className='onboarding-modal__nav onboarding-modal__done'><FormattedMessage id='onboarding.next' defaultMessage='Done' /></a>;
    }

    return (
      <div className='modal-root__modal onboarding-modal'>
        <div className='onboarding-modal__pager'>
          {pages.map((page, i) => <div key={i} className={i === currentIndex ? 'active' : null}>{page}</div>)}
        </div>

        <div className='onboarding-modal__paginator'>
          <div>
            <a href='#' className='onboarding-modal__skip' onClick={this.handleSkip}><FormattedMessage id='onboarding.skip' defaultMessage='Skip' /></a>
          </div>

          <div className='onboarding-modal__dots'>
            {pages.map((_, i) => <div key={i} onClick={this.handleDot.bind(null, i)} className={`onboarding-modal__dot ${i === currentIndex ? 'active' : ''}`} />)}
          </div>

          <div>
            {nextOrDoneBtn}
          </div>
        </div>
      </div>
    );
  }

});

export default connect(mapStateToProps)(injectIntl(OnboardingModal));
