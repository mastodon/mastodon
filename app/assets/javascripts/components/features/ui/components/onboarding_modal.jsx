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

const PageTwo = ({ admin }) => (
  <div className='onboarding-modal__page onboarding-modal__page-two'>
    <p>
      <FormattedMessage id='onboarding.page_two.admin' defaultMessage="Your instance's admin is {admin}." values={{ admin: <Permalink href={admin.get('url')} to={`/accounts/${admin.get('id')}`}>@{admin.get('acct')}</Permalink> }} />
      <br />
      <FormattedMessage id='onboarding.page_two.read_guidelines' defaultMessage='Please read the {guidelines} of your instance.' values={{ guidelines: <a href='/about/more' target='_blank'><FormattedMessage id='onboarding.page_two.guidelines' defaultMessage='community guidelines' /></a> }}/>
    </p>
    <p><FormattedMessage id='onboarding.page_two.read_guidelines' defaultMessage='Mastodon is free open-source software. You can report bugs, request features, or contribute to the code on {github}.' values={{ github: <a href='https://github.com/tootsuite/mastodon' target='_blank' rel='noopener'>GitHub</a> }} /></p>
    <p><FormattedMessage id='onboarding.page_two.apps_available' defaultMessage='There are {apps} available for iOS and Android.' values={{ apps: <a href='https://github.com/tootsuite/mastodon/blob/master/docs/Using-Mastodon/Apps.md' target='_blank' rel='noopener'><FormattedMessage id='onboarding.page_two.various_app' defaultMessage='mobile apps' /></a> }} /></p>
    <p><strong><FormattedMessage id='onboarding.page_two.have_fun' defaultMessage='Have fun!' /></strong></p>
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
      <PageTwo admin={admin} />
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
