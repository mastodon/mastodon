import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ReactSwipeableViews from 'react-swipeable-views';
import classNames from 'classnames';
import Permalink from '../../../components/permalink';
import ComposeForm from '../../compose/components/compose_form';
import Search from '../../compose/components/search';
import NavigationBar from '../../compose/components/navigation_bar';
import ColumnHeader from './column_header';
import { List as ImmutableList } from 'immutable';
import { me } from '../../../initial_state';

const noop = () => { };

const messages = defineMessages({
  home_title: { id: 'column.home', defaultMessage: 'Home' },
  notifications_title: { id: 'column.notifications', defaultMessage: 'Notifications' },
  local_title: { id: 'column.community', defaultMessage: 'Local timeline' },
  federated_title: { id: 'column.public', defaultMessage: 'Federated timeline' },
});

const PageOne = ({ acct, domain }) => (
  <div className='onboarding-modal__page onboarding-modal__page-one'>
    <div className='onboarding-modal__page-one__lead'>
      <h1><FormattedMessage id='onboarding.page_one.welcome' defaultMessage='Welcome to Mastodon!' /></h1>
      <p><FormattedMessage id='onboarding.page_one.federation' defaultMessage='Mastodon is a network of independent servers joining up to make one larger social network. We call these servers instances.' /></p>
    </div>

    <div className='onboarding-modal__page-one__extra'>
      <div className='display-case'>
        <div className='display-case__label'>
          <FormattedMessage id='onboarding.page_one.full_handle' defaultMessage='Your full handle' />
        </div>

        <div className='display-case__case'>
          @{acct}@{domain}
        </div>
      </div>

      <p><FormattedMessage id='onboarding.page_one.handle_hint' defaultMessage='This is what you would tell your friends to search for.' /></p>
    </div>
  </div>
);

PageOne.propTypes = {
  acct: PropTypes.string.isRequired,
  domain: PropTypes.string.isRequired,
};

const PageTwo = ({ myAccount }) => (
  <div className='onboarding-modal__page onboarding-modal__page-two'>
    <div className='figure non-interactive'>
      <div className='pseudo-drawer'>
        <NavigationBar account={myAccount} />

        <ComposeForm
          text='Awoo! #introductions'
          suggestions={ImmutableList()}
          mentionedDomains={[]}
          spoiler={false}
          onChange={noop}
          onSubmit={noop}
          onPaste={noop}
          onPickEmoji={noop}
          onChangeSpoilerText={noop}
          onClearSuggestions={noop}
          onFetchSuggestions={noop}
          onSuggestionSelected={noop}
          showSearch
        />
      </div>
    </div>

    <p><FormattedMessage id='onboarding.page_two.compose' defaultMessage='Write posts from the compose column. You can upload images, change privacy settings, and add content warnings with the icons below.' /></p>
  </div>
);

PageTwo.propTypes = {
  myAccount: ImmutablePropTypes.map.isRequired,
};

const PageThree = ({ myAccount }) => (
  <div className='onboarding-modal__page onboarding-modal__page-three'>
    <div className='figure non-interactive'>
      <Search
        value=''
        onChange={noop}
        onSubmit={noop}
        onClear={noop}
        onShow={noop}
      />

      <div className='pseudo-drawer'>
        <NavigationBar account={myAccount} />
      </div>
    </div>

    <p><FormattedMessage id='onboarding.page_three.search' defaultMessage='Use the search bar to find people and look at hashtags, such as {illustration} and {introductions}. To look for a person who is not on this instance, use their full handle.' values={{ illustration: <Permalink to='/timelines/tag/illustration' href='/tags/illustration'>#illustration</Permalink>, introductions: <Permalink to='/timelines/tag/introductions' href='/tags/introductions'>#introductions</Permalink> }} /></p>
    <p><FormattedMessage id='onboarding.page_three.profile' defaultMessage='Edit your profile to change your avatar, bio, and display name. There, you will also find other preferences.' /></p>
  </div>
);

PageThree.propTypes = {
  myAccount: ImmutablePropTypes.map.isRequired,
};

const PageFour = ({ domain, intl }) => (
  <div className='onboarding-modal__page onboarding-modal__page-four'>
    <div className='onboarding-modal__page-four__columns'>
      <div className='row'>
        <div>
          <div className='figure non-interactive'><ColumnHeader icon='home' type={intl.formatMessage(messages.home_title)} /></div>
          <p><FormattedMessage id='onboarding.page_four.home' defaultMessage='The home timeline shows posts from people you follow.' /></p>
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
  intl: PropTypes.object.isRequired,
};

const PageSix = ({ admin, domain }) => {
  let adminSection = '';

  if (admin) {
    adminSection = (
      <p>
        <FormattedMessage id='onboarding.page_six.admin' defaultMessage="Your instance's admin is {admin}." values={{ admin: <Permalink href={admin.get('url')} to={`/accounts/${admin.get('id')}`}>@{admin.get('acct')}</Permalink> }} />
        <br />
        <FormattedMessage id='onboarding.page_six.read_guidelines' defaultMessage="Please read {domain}'s {guidelines}!" values={{ domain, guidelines: <a href='/about/more' target='_blank'><FormattedMessage id='onboarding.page_six.guidelines' defaultMessage='community guidelines' /></a> }} />
      </p>
    );
  }

  return (
    <div className='onboarding-modal__page onboarding-modal__page-six'>
      <h1><FormattedMessage id='onboarding.page_six.almost_done' defaultMessage='Almost done...' /></h1>
      {adminSection}
      <p><FormattedMessage id='onboarding.page_six.github' defaultMessage='Mastodon is free open-source software. You can report bugs, request features, or contribute to the code on {github}.' values={{ github: <a href='https://github.com/tootsuite/mastodon' target='_blank' rel='noopener'>GitHub</a> }} /></p>
      <p><FormattedMessage id='onboarding.page_six.apps_available' defaultMessage='There are {apps} available for iOS, Android and other platforms.' values={{ apps: <a href='https://joinmastodon.org/apps' target='_blank' rel='noopener'><FormattedMessage id='onboarding.page_six.various_app' defaultMessage='mobile apps' /></a> }} /></p>
      <p><em><FormattedMessage id='onboarding.page_six.appetoot' defaultMessage='Bon Appetoot!' /></em></p>
    </div>
  );
};

PageSix.propTypes = {
  admin: ImmutablePropTypes.map,
  domain: PropTypes.string.isRequired,
};

const mapStateToProps = state => ({
  myAccount: state.getIn(['accounts', me]),
  admin: state.getIn(['accounts', state.getIn(['meta', 'admin'])]),
  domain: state.getIn(['meta', 'domain']),
});

export default @connect(mapStateToProps)
@injectIntl
class OnboardingModal extends React.PureComponent {

  static propTypes = {
    onClose: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    myAccount: ImmutablePropTypes.map.isRequired,
    domain: PropTypes.string.isRequired,
    admin: ImmutablePropTypes.map,
  };

  state = {
    currentIndex: 0,
  };

  componentWillMount() {
    const { myAccount, admin, domain, intl } = this.props;
    this.pages = [
      <PageOne acct={myAccount.get('acct')} domain={domain} />,
      <PageTwo myAccount={myAccount} />,
      <PageThree myAccount={myAccount} />,
      <PageFour domain={domain} intl={intl} />,
      <PageSix admin={admin} domain={domain} />,
    ];
  };

  componentDidMount() {
    window.addEventListener('keyup', this.handleKeyUp);
  }

  componentWillUnmount() {
    window.addEventListener('keyup', this.handleKeyUp);
  }

  handleSkip = (e) => {
    e.preventDefault();
    this.props.onClose();
  }

  handleDot = (e) => {
    const i = Number(e.currentTarget.getAttribute('data-index'));
    e.preventDefault();
    this.setState({ currentIndex: i });
  }

  handlePrev = () => {
    this.setState(({ currentIndex }) => ({
      currentIndex: Math.max(0, currentIndex - 1),
    }));
  }

  handleNext = () => {
    const { pages } = this;
    this.setState(({ currentIndex }) => ({
      currentIndex: Math.min(currentIndex + 1, pages.length - 1),
    }));
  }

  handleSwipe = (index) => {
    this.setState({ currentIndex: index });
  }

  handleKeyUp = ({ key }) => {
    switch (key) {
    case 'ArrowLeft':
      this.handlePrev();
      break;
    case 'ArrowRight':
      this.handleNext();
      break;
    }
  }

  handleClose = () => {
    this.props.onClose();
  }

  render () {
    const { pages } = this;
    const { currentIndex } = this.state;
    const hasMore = currentIndex < pages.length - 1;

    const nextOrDoneBtn = hasMore ? (
      <button onClick={this.handleNext} className='onboarding-modal__nav onboarding-modal__next shake-bottom'>
        <FormattedMessage id='onboarding.next' defaultMessage='Next' /> <i className='fa fa-fw fa-chevron-right' />
      </button>
    ) : (
      <button onClick={this.handleClose} className='onboarding-modal__nav onboarding-modal__done shake-bottom'>
        <FormattedMessage id='onboarding.done' defaultMessage='Done' /> <i className='fa fa-fw fa-check' />
      </button>
    );

    return (
      <div className='modal-root__modal onboarding-modal'>
        <ReactSwipeableViews index={currentIndex} onChangeIndex={this.handleSwipe} className='onboarding-modal__pager'>
          {pages.map((page, i) => {
            const className = classNames('onboarding-modal__page__wrapper', `onboarding-modal__page__wrapper-${i}`, {
              'onboarding-modal__page__wrapper--active': i === currentIndex,
            });

            return (
              <div key={i} className={className}>{page}</div>
            );
          })}
        </ReactSwipeableViews>

        <div className='onboarding-modal__paginator'>
          <div>
            <button
              onClick={this.handleSkip}
              className='onboarding-modal__nav onboarding-modal__skip'
            >
              <FormattedMessage id='onboarding.skip' defaultMessage='Skip' />
            </button>
          </div>

          <div className='onboarding-modal__dots'>
            {pages.map((_, i) => {
              const className = classNames('onboarding-modal__dot', {
                active: i === currentIndex,
              });

              return (
                <div
                  key={`dot-${i}`}
                  role='button'
                  tabIndex='0'
                  data-index={i}
                  onClick={this.handleDot}
                  className={className}
                />
              );
            })}
          </div>

          <div>
            {nextOrDoneBtn}
          </div>
        </div>
      </div>
    );
  }

}
