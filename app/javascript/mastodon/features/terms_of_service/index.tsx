import { useState, useEffect } from 'react';

import {
  FormattedMessage,
  FormattedDate,
  useIntl,
  defineMessages,
} from 'react-intl';

import { Helmet } from 'react-helmet';

import { apiGetTermsOfService } from 'mastodon/api/instance';
import type { ApiTermsOfServiceJSON } from 'mastodon/api_types/instance';
import { Column } from 'mastodon/components/column';
import { Skeleton } from 'mastodon/components/skeleton';
import BundleColumnError from 'mastodon/features/ui/components/bundle_column_error';

const messages = defineMessages({
  title: { id: 'terms_of_service.title', defaultMessage: 'Terms of Service' },
});

const TermsOfService: React.FC<{
  multiColumn: boolean;
}> = ({ multiColumn }) => {
  const intl = useIntl();
  const [response, setResponse] = useState<ApiTermsOfServiceJSON>();
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    apiGetTermsOfService()
      .then((data) => {
        setResponse(data);
        setLoading(false);
        return '';
      })
      .catch(() => {
        setLoading(false);
      });
  }, []);

  if (!loading && !response) {
    return <BundleColumnError multiColumn={multiColumn} errorType='routing' />;
  }

  return (
    <Column
      bindToDocument={!multiColumn}
      label={intl.formatMessage(messages.title)}
    >
      <div className='scrollable privacy-policy'>
        <div className='column-title'>
          <h3>
            <FormattedMessage
              id='terms_of_service.title'
              defaultMessage='Terms of Service'
            />
          </h3>
          <p>
            <FormattedMessage
              id='privacy_policy.last_updated'
              defaultMessage='Last updated {date}'
              values={{
                date: loading ? (
                  <Skeleton width='10ch' />
                ) : (
                  <FormattedDate
                    value={response?.updated_at}
                    year='numeric'
                    month='short'
                    day='2-digit'
                  />
                ),
              }}
            />
          </p>
        </div>

        {response && (
          <div
            className='privacy-policy__body prose'
            dangerouslySetInnerHTML={{ __html: response.content }}
          />
        )}
      </div>

      <Helmet>
        <title>{intl.formatMessage(messages.title)}</title>
        <meta name='robots' content='all' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default TermsOfService;
