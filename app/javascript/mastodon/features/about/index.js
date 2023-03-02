import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import Column from 'mastodon/components/column';
import LinkFooter from 'mastodon/features/ui/components/link_footer';
import { Helmet } from 'react-helmet';
import { fetchServer, fetchExtendedDescription, fetchDomainBlocks } from 'mastodon/actions/server';
import Account from 'mastodon/containers/account_container';
import Skeleton from 'mastodon/components/skeleton';
import Icon from 'mastodon/components/icon';
import classNames from 'classnames';
import appScreenshot from 'mastodon/../images/app-screenshot.png';

const messages = defineMessages({
  title: { id: 'column.about', defaultMessage: 'About' },
  rules: { id: 'about.rules', defaultMessage: 'Server rules' },
  blocks: { id: 'about.blocks', defaultMessage: 'Moderated servers' },
  silenced: { id: 'about.domain_blocks.silenced.title', defaultMessage: 'Limited' },
  silencedExplanation: { id: 'about.domain_blocks.silenced.explanation', defaultMessage: 'You will generally not see profiles and content from this server, unless you explicitly look it up or opt into it by following.' },
  suspended: { id: 'about.domain_blocks.suspended.title', defaultMessage: 'Suspended' },
  suspendedExplanation: { id: 'about.domain_blocks.suspended.explanation', defaultMessage: 'No data from this server will be processed, stored or exchanged, making any interaction or communication with users from this server impossible.' },
});

const severityMessages = {
  silence: {
    title: messages.silenced,
    explanation: messages.silencedExplanation,
  },

  suspend: {
    title: messages.suspended,
    explanation: messages.suspendedExplanation,
  },
};

const mapStateToProps = state => ({
  server: state.getIn(['server', 'server']),
  extendedDescription: state.getIn(['server', 'extendedDescription']),
  domainBlocks: state.getIn(['server', 'domainBlocks']),
});

class Section extends React.PureComponent {

  static propTypes = {
    title: PropTypes.string,
    children: PropTypes.node,
    open: PropTypes.bool,
    onOpen: PropTypes.func,
  };

  state = {
    collapsed: !this.props.open,
  };

  handleClick = () => {
    const { onOpen } = this.props;
    const { collapsed } = this.state;

    this.setState({ collapsed: !collapsed }, () => onOpen && onOpen());
  }

  render () {
    const { title, children } = this.props;
    const { collapsed } = this.state;

    return (
      <div className={classNames('about__section', { active: !collapsed })}>
        <div className='about__section__title' role='button' tabIndex='0' onClick={this.handleClick}>
          <Icon id={collapsed ? 'chevron-right' : 'chevron-down'} fixedWidth /> {title}
        </div>

        {!collapsed && (
          <div className='about__section__body'>{children}</div>
        )}
      </div>
    );
  }

}

export default @connect(mapStateToProps)
@injectIntl
class About extends React.PureComponent {

  static propTypes = {
    server: ImmutablePropTypes.map,
    extendedDescription: ImmutablePropTypes.map,
    domainBlocks: ImmutablePropTypes.contains({
      isLoading: PropTypes.bool,
      isAvailable: PropTypes.bool,
      items: ImmutablePropTypes.list,
    }),
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    multiColumn: PropTypes.bool,
  };

  componentDidMount () {
    const { dispatch } = this.props;
    dispatch(fetchServer());
    dispatch(fetchExtendedDescription());
  }

  handleDomainBlocksOpen = () => {
    const { dispatch } = this.props;
    dispatch(fetchDomainBlocks());
  }

  render () {
    const { multiColumn, intl, server, extendedDescription, domainBlocks } = this.props;
    const isLoading = server.get('isLoading');

    return (<>
      <section className='intro'>
        <div>
          <h1 className='heading'>
            A social network that's personal and private,
            <br />
            built on decentralized techonology of the future
          </h1>
          <div className='bullet-section'>
            <h3>
              <span className='bullet'>»</span>
              Ad-free, surveillance-free
              <br />
              <span className='bullet'>»</span>
              Real people&mdash;no influencers, bots, or companies
              <br />
              <span className='bullet'>»</span>
              Calm design, free from engagement algorithms
              <br />
              <span className='bullet'>»</span>
              Built on top of open source, decentralized protocols
              <br />
              <span className='bullet'>»</span>
              Follow your friends on other federated social networks, like Pixelfed or Mastodon
            </h3>
          </div>
        </div>
        <div>
          <img src={appScreenshot} />
        </div>
      </section>
    </>);
  }
}
