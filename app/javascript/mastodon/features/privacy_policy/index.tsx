import { useState, useEffect } from 'react';

import {
  FormattedMessage,
  FormattedDate,
  useIntl,
  defineMessages,
} from 'react-intl';

import { Helmet } from 'react-helmet';

import { apiGetPrivacyPolicy } from 'mastodon/api/instance';
import type { ApiPrivacyPolicyJSON } from 'mastodon/api_types/instance';
import { Column } from 'mastodon/components/column';
import { Skeleton } from 'mastodon/components/skeleton';

const messages = defineMessages({
  title: { id: 'privacy_policy.title', defaultMessage: 'Privacy Policy' },
});

const PrivacyPolicy: React.FC<{
  multiColumn: boolean;
}> = ({ multiColumn }) => {
  const intl = useIntl();
  const [response, setResponse] = useState<ApiPrivacyPolicyJSON>();
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    apiGetPrivacyPolicy()
      .then((data) => {
        setResponse(data);
        setLoading(false);
        return '';
      })
      .catch(() => {
        setLoading(false);
      });
  }, []);

  return (
    <Column
      bindToDocument={!multiColumn}
      label={intl.formatMessage(messages.title)}
    >
      <div className='scrollable privacy-policy'>
        <div className='column-title'>
          <h3>
            <FormattedMessage
              id='privacy_policy.title'
              defaultMessage='Privacy Policy'
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
export default PrivacyPolicy;
