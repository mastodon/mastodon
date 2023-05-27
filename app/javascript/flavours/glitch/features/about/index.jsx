import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import Column from 'flavours/glitch/components/column';
import LinkFooter from 'flavours/glitch/features/ui/components/link_footer';
import { Helmet } from 'react-helmet';
import { fetchServer, fetchExtendedDescription, fetchDomainBlocks } from 'flavours/glitch/actions/server';
import Account from 'flavours/glitch/containers/account_container';
import { Skeleton } from 'flavours/glitch/components/skeleton';
import { Icon } from 'flavours/glitch/components/icon';
import classNames from 'classnames';
import { ServerHeroImage } from 'flavours/glitch/components/server_hero_image';

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
  };

  render () {
    const { title, children } = this.props;
    const { collapsed } = this.state;

    return (
      <div className={classNames('about__section', { active: !collapsed })}>
        <div className='about__section__title' role='button' tabIndex={0} onClick={this.handleClick}>
          <Icon id={collapsed ? 'chevron-right' : 'chevron-down'} fixedWidth /> {title}
        </div>

        {!collapsed && (
          <div className='about__section__body'>{children}</div>
        )}
      </div>
    );
  }

}

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
  };

  render () {
    const { multiColumn, intl, server, extendedDescription, domainBlocks } = this.props;
    const isLoading = server.get('isLoading');

    return (
      <Column bindToDocument={!multiColumn} label={intl.formatMessage(messages.title)}>
        <div className='scrollable about'>
          <div className='about__header'>
            <ServerHeroImage blurhash={server.getIn(['thumbnail', 'blurhash'])} src={server.getIn(['thumbnail', 'url'])} srcSet={server.getIn(['thumbnail', 'versions'])?.map((value, key) => `${value} ${key.replace('@', '')}`).join(', ')} className='about__header__hero' />
            <h1>{isLoading ? <Skeleton width='10ch' /> : server.get('domain')}</h1>
            <p><FormattedMessage id='about.powered_by' defaultMessage='Decentralized social media powered by {mastodon}' values={{ mastodon: <a href='https://joinmastodon.org' className='about__mail' target='_blank'>Mastodon</a> }} /></p>
          </div>

          <div className='about__meta'>
            <div className='about__meta__column'>
              <h4><FormattedMessage id='server_banner.administered_by' defaultMessage='Administered by:' /></h4>

              <Account id={server.getIn(['contact', 'account', 'id'])} size={36} />
            </div>

            <hr className='about__meta__divider' />

            <div className='about__meta__column'>
              <h4><FormattedMessage id='about.contact' defaultMessage='Contact:' /></h4>

              {isLoading ? <Skeleton width='10ch' /> : <a className='about__mail' href={`mailto:${server.getIn(['contact', 'email'])}`}>{server.getIn(['contact', 'email'])}</a>}
            </div>
          </div>

          <Section open title={intl.formatMessage(messages.title)}>
            {extendedDescription.get('isLoading') ? (
              <>
                <Skeleton width='100%' />
                <br />
                <Skeleton width='100%' />
                <br />
                <Skeleton width='100%' />
                <br />
                <Skeleton width='70%' />
              </>
            ) : (extendedDescription.get('content')?.length > 0 ? (
              <div
                className='prose'
                dangerouslySetInnerHTML={{ __html: extendedDescription.get('content') }}
              />
            ) : (
              <p><FormattedMessage id='about.not_available' defaultMessage='This information has not been made available on this server.' /></p>
            ))}
          </Section>

          <Section title={intl.formatMessage(messages.rules)}>
            {!isLoading && (server.get('rules').isEmpty() ? (
              <p><FormattedMessage id='about.not_available' defaultMessage='This information has not been made available on this server.' /></p>
            ) : (
              <ol className='rules-list'>
                {server.get('rules').map(rule => (
                  <li key={rule.get('id')}>
                    <span className='rules-list__text'>{rule.get('text')}</span>
                  </li>
                ))}
              </ol>
            ))}
          </Section>

          <Section title={intl.formatMessage(messages.blocks)} onOpen={this.handleDomainBlocksOpen}>
            {domainBlocks.get('isLoading') ? (
              <>
                <Skeleton width='100%' />
                <br />
                <Skeleton width='70%' />
              </>
            ) : (domainBlocks.get('isAvailable') ? (
              <>
                <p><FormattedMessage id='about.domain_blocks.preamble' defaultMessage='Mastodon generally allows you to view content from and interact with users from any other server in the fediverse. These are the exceptions that have been made on this particular server.' /></p>

                <div className='about__domain-blocks'>
                  {domainBlocks.get('items').map(block => (
                    <div className='about__domain-blocks__domain' key={block.get('domain')}>
                      <div className='about__domain-blocks__domain__header'>
                        <h6><span title={`SHA-256: ${block.get('digest')}`}>{block.get('domain')}</span></h6>
                        <span className='about__domain-blocks__domain__type' title={intl.formatMessage(severityMessages[block.get('severity')].explanation)}>{intl.formatMessage(severityMessages[block.get('severity')].title)}</span>
                      </div>

                      <p>{(block.get('comment') || '').length > 0 ? block.get('comment') : <FormattedMessage id='about.domain_blocks.no_reason_available' defaultMessage='Reason not available' />}</p>
                    </div>
                  ))}
                </div>
              </>
            ) : (
              <p><FormattedMessage id='about.not_available' defaultMessage='This information has not been made available on this server.' /></p>
            ))}
          </Section>

          <LinkFooter />

          <div className='about__footer'>
            <p><FormattedMessage id='about.fork_disclaimer' defaultMessage='Glitch-soc is free open source software forked from Mastodon.' /></p>
            <p><FormattedMessage id='about.disclaimer' defaultMessage='Mastodon is free, open-source software, and a trademark of Mastodon gGmbH.' /></p>
          </div>
        </div>

        <Helmet>
          <title>{intl.formatMessage(messages.title)}</title>
          <meta name='robots' content='all' />
        </Helmet>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(About));
