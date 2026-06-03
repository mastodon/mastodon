import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { defineMessages, FormattedMessage } from 'react-intl';

import { Helmet } from '@unhead/react/helmet';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import { injectIntl } from '@/mastodon/components/intl';
import { fetchServer, fetchExtendedDescription, fetchDomainBlocks  } from 'mastodon/actions/server';
import { Account } from 'mastodon/components/account';
import Column from 'mastodon/components/column';
import { ServerHeroImage } from 'mastodon/components/server_hero_image';
import { Skeleton } from 'mastodon/components/skeleton';
import { LinkFooter} from 'mastodon/features/ui/components/link_footer';

import { Section } from './components/section';
import { RulesSection } from './components/rules';
import { getColumnSkipLinkId } from '../ui/components/skip_links';

const messages = defineMessages({
  title: { id: 'column.about', defaultMessage: 'About' },
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
  server: state.server.server,
  locale: state.getIn(['meta', 'locale']),
  extendedDescription: state.server.extendedDescription,
  domainBlocks: state.server.domainBlocks,
});

class About extends PureComponent {

  static propTypes = {
    server: ImmutablePropTypes.map,
    locale: ImmutablePropTypes.string,
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
    const { multiColumn, intl, server, extendedDescription, domainBlocks, locale } = this.props;
    const isLoading = server.isLoading;

    return (
      <Column bindToDocument={!multiColumn} label={intl.formatMessage(messages.title)}>
        <div className='scrollable about' id={getColumnSkipLinkId(1)}>
          <div className='about__header'>
            <ServerHeroImage
              withAltBadge
              alt={server.item?.thumbnail.description ?? ''}
              blurhash={server.item?.thumbnail.blurhash}
              src={server.item?.thumbnail.url}
              srcSet={Object.keys(server.item?.thumbnail.versions ?? {}).map((key) => `${server.item?.thumbnail.versions && server.item.thumbnail.versions[key]} ${key.replace('@', '')}`).join(', ')}
              className='about__header__hero'
            />
            <h1>{isLoading ? <Skeleton width='10ch' /> : server.domain}</h1>
            <p><FormattedMessage id='about.powered_by' defaultMessage='Decentralized social media powered by {mastodon}' values={{ mastodon: <a href='https://joinmastodon.org' className='about__mail' target='_blank' rel='noopener'>Mastodon</a> }} /></p>
          </div>

          <div className='about__meta'>
            <div className='about__meta__column'>
              <h4><FormattedMessage id='server_banner.administered_by' defaultMessage='Administered by:' /></h4>

              <Account id={server.item?.contact?.account?.id} size={36} minimal />
            </div>

            <hr className='about__meta__divider' />

            <div className='about__meta__column'>
              <h4><FormattedMessage id='about.contact' defaultMessage='Contact:' /></h4>

              {isLoading ? <Skeleton width='10ch' /> : <a className='about__mail' href={`mailto:${server.item?.contact?.email}`}>{server.item?.contact?.email}</a>}
            </div>
          </div>

          <Section open title={intl.formatMessage(messages.title)}>
            {extendedDescription.isLoading ? (
              <>
                <Skeleton width='100%' />
                <br />
                <Skeleton width='100%' />
                <br />
                <Skeleton width='100%' />
                <br />
                <Skeleton width='70%' />
              </>
            ) : (extendedDescription.item?.content?.length > 0 ? (
              <div
                className='prose'
                dangerouslySetInnerHTML={{ __html: extendedDescription.item?.content }}
              />
            ) : (
              <p><FormattedMessage id='about.not_available' defaultMessage='This information has not been made available on this server.' /></p>
            ))}
          </Section>

          <RulesSection />

          <Section title={intl.formatMessage(messages.blocks)} onOpen={this.handleDomainBlocksOpen}>
            {domainBlocks.isLoading ? (
              <>
                <Skeleton width='100%' />
                <br />
                <Skeleton width='70%' />
              </>
            ) : (domainBlocks.isAvailable ? (
              <>
                <p><FormattedMessage id='about.domain_blocks.preamble' defaultMessage='Mastodon generally allows you to view content from and interact with users from any other server in the fediverse. These are the exceptions that have been made on this particular server.' /></p>

                {domainBlocks.items.length > 0 && (
                  <div className='about__domain-blocks'>
                    {domainBlocks.items.map(block => (
                      <div className='about__domain-blocks__domain' key={block.domain}>
                        <div className='about__domain-blocks__domain__header'>
                          <h6><span title={`SHA-256: ${block.digest}`}>{block.domain}</span></h6>
                          <span className='about__domain-blocks__domain__type' title={intl.formatMessage(severityMessages[block.severity].explanation)}>{intl.formatMessage(severityMessages[block.severity].title)}</span>
                        </div>

                        <p>{(block.comment ?? '').length > 0 ? block.comment : <FormattedMessage id='about.domain_blocks.no_reason_available' defaultMessage='Reason not available' />}</p>
                      </div>
                    ))}
                  </div>
                )}
              </>
            ) : (
              <p><FormattedMessage id='about.not_available' defaultMessage='This information has not been made available on this server.' /></p>
            ))}
          </Section>

          <LinkFooter context='about' />

          <div className='about__footer'>
            <p><FormattedMessage id='about.disclaimer' defaultMessage='Mastodon is free, open-source software, and a trademark of Mastodon GmbH.' /></p>
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
