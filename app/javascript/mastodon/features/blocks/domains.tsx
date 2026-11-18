import { useEffect, useCallback, useState } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import { Helmet } from '@unhead/react/helmet';

import { apiGetDomainBlocks } from 'mastodon/api/domain_blocks';
import { Domain } from 'mastodon/components/domain';
import ScrollableList from 'mastodon/components/scrollable_list';

const DomainBlocks: React.FC<{ multiColumn: boolean }> = ({ multiColumn }) => {
  const intl = useIntl();
  const [domains, setDomains] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);
  const [next, setNext] = useState<string | undefined>();
  const hasMore = !!next;

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

  const handleUnblock = useCallback((domain: string) => {
    setDomains((prev) => prev.filter((d) => d !== domain));
  }, []);

  return (
    <>
      <ScrollableList
        scrollKey='domain_blocks'
        onLoadMore={handleLoadMore}
        hasMore={hasMore}
        isLoading={loading}
        showLoading={loading && domains.length === 0}
        emptyMessage={
          <FormattedMessage
            id='empty_column.domain_blocks'
            defaultMessage="You haven't blocked any domains yet."
          />
        }
        trackScroll={!multiColumn}
        bindToDocument={!multiColumn}
      >
        {domains.map((domain) => (
          <Domain key={domain} domain={domain} onUnblock={handleUnblock} />
        ))}
      </ScrollableList>

      <Helmet>
        <title>
          {intl.formatMessage({
            id: 'column.domain_blocks',
            defaultMessage: 'Blocked Domains',
          })}
        </title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </>
  );
};

// eslint-disable-next-line import/no-default-export
export default DomainBlocks;
