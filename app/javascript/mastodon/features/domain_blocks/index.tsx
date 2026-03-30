import { useEffect, useRef, useCallback, useState } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';

import BlockIcon from '@/material-icons/400-24px/block-fill.svg?react';
import { apiGetDomainBlocks } from 'mastodon/api/domain_blocks';
import { Column } from 'mastodon/components/column';
import type { ColumnRef } from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import { Domain } from 'mastodon/components/domain';
import ScrollableList from 'mastodon/components/scrollable_list';

const messages = defineMessages({
  heading: { id: 'column.domain_blocks', defaultMessage: 'Blocked domains' },
});

const Blocks: React.FC<{ multiColumn: boolean }> = ({ multiColumn }) => {
  const intl = useIntl();
  const [domains, setDomains] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);
  const [next, setNext] = useState<string | undefined>();
  const hasMore = !!next;
  const columnRef = useRef<ColumnRef>(null);

  useEffect(() => {
    void apiGetDomainBlocks()
      .then(({ domains, links }) => {
        const next = links.refs.find((link) => link.rel === 'next');

        setLoading(false);
        setDomains(domains);
        setNext(next?.uri);

        return '';
      })
      .catch(() => {
        setLoading(false);
      });
  }, []);

  const handleLoadMore = useCallback(() => {
    setLoading(true);

    void apiGetDomainBlocks(next)
      .then(({ domains, links }) => {
        const next = links.refs.find((link) => link.rel === 'next');

        setLoading(false);
        setDomains((previousDomains) => [...previousDomains, ...domains]);
        setNext(next?.uri);

        return '';
      })
      .catch(() => {
        setLoading(false);
      });
  }, [setLoading, setDomains, setNext, next]);

  const handleHeaderClick = useCallback(() => {
    columnRef.current?.scrollTop();
  }, []);

  const emptyMessage = (
    <FormattedMessage
      id='empty_column.domain_blocks'
      defaultMessage='There are no blocked domains yet.'
    />
  );

  return (
    <Column
      bindToDocument={!multiColumn}
      ref={columnRef}
      label={intl.formatMessage(messages.heading)}
    >
      <ColumnHeader
        icon='ban'
        iconComponent={BlockIcon}
        title={intl.formatMessage(messages.heading)}
        onClick={handleHeaderClick}
        multiColumn={multiColumn}
        showBackButton
      />

      <ScrollableList
        scrollKey='domain_blocks'
        onLoadMore={handleLoadMore}
        hasMore={hasMore}
        isLoading={loading}
        showLoading={loading && domains.length === 0}
        emptyMessage={emptyMessage}
        trackScroll={!multiColumn}
        bindToDocument={!multiColumn}
      >
        {domains.map((domain) => (
          <Domain key={domain} domain={domain} />
        ))}
      </ScrollableList>

      <Helmet>
        <title>{intl.formatMessage(messages.heading)}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default Blocks;
