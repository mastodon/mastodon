import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import Permalink from '../../../components/permalink';
import { TransitionMotion, spring } from 'react-motion';
import ComposeForm from '../../compose/components/compose_form';
import Search from '../../compose/components/search';
import NavigationBar from '../../compose/components/navigation_bar';
import ColumnHeader from './column_header';
import Immutable from 'immutable';

const messages = defineMessages({
  home_title: { id: 'column.home', defaultMessage: 'Home' },
  notifications_title: { id: 'column.notifications', defaultMessage: 'Notifications' },
  local_title: { id: 'column.community', defaultMessage: 'Local timeline' },
  federated_title: { id: 'column.public', defaultMessage: 'Federated timeline' }
});

const PageOne = ({ acct, domain }) => (
  <div className='onboarding-modal__page onboarding-modal__page-one'>
    <div style={{ flex: '0 0 auto' }}>
      <div className='onboarding-modal__page-one__elephant-friend' />
    </div>

    <div>
      <h1><FormattedMessage id='onboarding.page_one.welcome' defaultMessage='Welcome to Mastodon!' /></h1>
      <p><FormattedMessage id='onboarding.page_one.federation' defaultMessage='Mastodon is a network of independent servers joining up to make one larger social network. We call these servers instances.' /></p>
      <p><FormattedMessage id='onboarding.page_one.handle' defaultMessage='You are on {domain}, so your full handle is {handle}' values={{ domain, handle: <strong>{acct}@{domain}</strong> }}/></p>
    </div>
  </div>
);

PageOne.propTypes = {
  acct: PropTypes.string.isRequired,
  domain: PropTypes.string.isRequired
};

const PageTwo = ({ me }) => (
  <div className='onboarding-modal__page onboarding-modal__page-two'>
    <div className='figure non-interactive'>
      <div className='pseudo-drawer'>
        <NavigationBar account={me} />
      </div>
      <ComposeForm
        text='Awoo! #introductions'
        suggestions={Immutable.List()}
        mentionedDomains={[]}
        spoiler={false}
        onChange={() => {}}
        onSubmit={() => {}}
        onPaste={() => {}}
        onPickEmoji={() => {}}
        onChangeSpoilerText={() => {}}
        onClearSuggestions={() => {}}
        onFetchSuggestions={() => {}}
        onSuggestionSelected={() => {}}
      />
    </div>

    <p><FormattedMessage id='onboarding.page_two.compose' defaultMessage='Write posts from the compose column. You can upload images, change privacy settings, and add content warnings with the icons below.' /></p>
  </div>
);

PageTwo.propTypes = {
  me: ImmutablePropTypes.map.isRequired,
};

const PageThree = ({ me, domain }) => (
  <div className='onboarding-modal__page onboarding-modal__page-three'>
    <div className='figure non-interactive'>
      <Search
        value=''
        onChange={() => {}}
        onSubmit={() => {}}
        onClear={() => {}}
        onShow={() => {}}
      />

      <div className='pseudo-drawer'>
        <NavigationBar account={me} />
      </div>
    </div>

    <p><FormattedMessage id='onboarding.page_three.search' defaultMessage='Use the search bar to find people and look at hashtags, such as {illustration} and {introductions}. To look for a person who is not on this instance, use their full handle.' values={{ illustration: <Permalink to='/timelines/tag/illustration' href='/tags/illustration'>#illustration</Permalink>, introductions: <Permalink to='/timelines/tag/introductions' href='/tags/introductions'>#introductions</Permalink> }}/></p>
    <p><FormattedMessage id='onboarding.page_three.profile' defaultMessage='Edit your profile to change your avatar, bio, and display name. There, you will also find other preferences.' /></p>
  </div>
);

PageThree.propTypes = {
  me: ImmutablePropTypes.map.isRequired,
  domain: PropTypes.string.isRequired
};

const PageFour = ({ domain, intl }) => (
  <div className='onboarding-modal__page onboarding-modal__page-four'>
    <div className='onboarding-modal__page-four__columns'>
      <div className='row'>
        <div>
          <div className='figure non-interactive'><ColumnHeader icon='home' type={intl.formatMessage(messages.home_title)} /></div>
          <p><FormattedMessage id='onboarding.page_four.home' defaultMessage='The home timeline shows posts from people you follow.'/></p>
        </div>

        <div>
          <div className='figure non-interactive'><ColumnHeader icon='bell' type={intl.formatMessage(messages.notifications_title)} /></div>
          <p><FormattedMessage id='onboarding.page_four.notifications' defaultMessage='The notifications column shows when someone interacts with you.' /></p>
        </div>
      </div>

      <div className='row'>
        <div>
          <div className='figure non-interactive' style={{ marginBottom: 0 }}><ColumnHeader icon='users' type={intl.formatMessage(messages.local_title)} /></div>
        </div>

        <div>
          <div className='figure non-interactive' style={{ marginBottom: 0 }}><ColumnHeader icon='globe' type={intl.formatMessage(messages.federated_title)} /></div>
        </div>
      </div>

      <p><FormattedMessage id='onboarding.page_five.public_timelines' defaultMessage='The local timeline shows public posts from everyone on {domain}. The federated timeline shows public posts from everyone who people on {domain} follow. These are the Public Timelines, a great way to discover new people.' values={{ domain }} /></p>
    </div>
  </div>
);

PageFour.propTypes = {
  domain: PropTypes.string.isRequired,
  intl: PropTypes.object.isRequired
};

const PageSix = ({ admin, domain }) => {
  let adminSection = '';

  if (admin) {
    adminSection = (
      <p>
        <FormattedMessage id='onboarding.page_six.admin' defaultMessage="Your instance's admin is {admin}." values={{ admin: <Permalink href={admin.get('url')} to={`/accounts/${admin.get('id')}`}>@{admin.get('acct')}</Permalink> }} />
        <br />
        <FormattedMessage id='onboarding.page_six.read_guidelines' defaultMessage="Please read {domain}'s {guidelines}!" values={{domain, guidelines: <a href='/about/more' target='_blank'><FormattedMessage id='onboarding.page_six.guidelines' defaultMessage='community guidelines' /></a> }}/>
      </p>
    );
  }

  return (
    <div className='onboarding-modal__page onboarding-modal__page-six'>
      <h1><FormattedMessage id='onboarding.page_six.almost_done' defaultMessage='Almost done...' /></h1>
      {adminSection}
      <p><FormattedMessage id='onboarding.page_six.github' defaultMessage='Mastodon is free open-source software. You can report bugs, request features, or contribute to the code on {github}.' values={{ github: <a href='https://github.com/tootsuite/mastodon' target='_blank' rel='noopener'>GitHub</a> }} /></p>
      <p><FormattedMessage id='onboarding.page_six.apps_available' defaultMessage='There are {apps} available for iOS, Android and other platforms.' values={{ apps: <a href='https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/Apps.md' target='_blank' rel='noopener'><FormattedMessage id='onboarding.page_six.various_app' defaultMessage='mobile apps' /></a> }} /></p>
      <p><em><FormattedMessage id='onboarding.page_six.appetoot' defaultMessage='Bon Appetoot!' /></em></p>
    </div>
  );
};

PageSix.propTypes = {
  admin: ImmutablePropTypes.map,
  domain: PropTypes.string.isRequired
};

const mapStateToProps = state => ({
  me: state.getIn(['accounts', state.getIn(['meta', 'me'])]),
  admin: state.getIn(['accounts', state.getIn(['meta', 'admin'])]),
  domain: state.getIn(['meta', 'domain'])
});

class OnboardingModal extends React.PureComponent {

  static propTypes = {
    onClose: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    me: ImmutablePropTypes.map.isRequired,
    domain: PropTypes.string.isRequired,
    admin: ImmutablePropTypes.map
  };

  state = {
    currentIndex: 0
  };

  handleSkip = (e) => {
    e.preventDefault();
    this.props.onClose();
  }

  handleDot = (i, e) => {
    e.preventDefault();
    this.setState({ currentIndex: i });
  }

  handleNext = (maxNum, e) => {
    e.preventDefault();

    if (this.state.currentIndex < maxNum - 1) {
      this.setState({ currentIndex: this.state.currentIndex + 1 });
    } else {
      this.props.onClose();
    }
  }

  render () {
    const { me, admin, domain, intl } = this.props;

    const pages = [
      <PageOne acct={me.get('acct')} domain={domain} />,
      <PageTwo me={me} />,
      <PageThree me={me} domain={domain} />,
      <PageFour domain={domain} intl={intl} />,
      <PageSix admin={admin} domain={domain} />
    ];

    const { currentIndex } = this.state;
    const hasMore = currentIndex < pages.length - 1;

    let nextOrDoneBtn;

    if(hasMore) {
      nextOrDoneBtn = <a href='#' onClick={this.handleNext.bind(null, pages.length)} className='onboarding-modal__nav onboarding-modal__next'><FormattedMessage id='onboarding.next' defaultMessage='Next' /></a>;
    } else {
      nextOrDoneBtn = <a href='#' onClick={this.handleNext.bind(null, pages.length)} className='onboarding-modal__nav onboarding-modal__done'><FormattedMessage id='onboarding.done' defaultMessage='Done' /></a>;
    }

    const styles = pages.map((page, i) => ({
      key: `page-${i}`,
      style: { opacity: spring(i === currentIndex ? 1 : 0) }
    }));

    return (
      <div className='modal-root__modal onboarding-modal'>
        <TransitionMotion styles={styles}>
          {interpolatedStyles =>
            <div className='onboarding-modal__pager'>
              {pages.map((page, i) =>
                <div key={`page-${i}`} style={{ opacity: interpolatedStyles[i].style.opacity, pointerEvents: i === currentIndex ? 'auto' : 'none' }}>{page}</div>
              )}
            </div>
          }
        </TransitionMotion>

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

}

export default connect(mapStateToProps)(injectIntl(OnboardingModal));
