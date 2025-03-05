import { useState, useEffect } from 'react';

import {
  FormattedMessage,
  FormattedDate,
  useIntl,
  defineMessages,
} from 'react-intl';

import { Helmet } from 'react-helmet';
import { Link, useParams } from 'react-router-dom';

import { apiGetTermsOfService } from 'mastodon/api/instance';
import type { ApiTermsOfServiceJSON } from 'mastodon/api_types/instance';
import { Column } from 'mastodon/components/column';
import BundleColumnError from 'mastodon/features/ui/components/bundle_column_error';

const messages = defineMessages({
  title: { id: 'terms_of_service.title', defaultMessage: 'Terms of Service' },
});

interface Params {
  date?: string;
}

const TermsOfService: React.FC<{
  multiColumn: boolean;
}> = ({ multiColumn }) => {
  const intl = useIntl();
  const { date } = useParams<Params>();
  const [response, setResponse] = useState<ApiTermsOfServiceJSON>();
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    apiGetTermsOfService(date)
      .then((data) => {
        setResponse(data);
        setLoading(false);
        return '';
      })
      .catch(() => {
        setLoading(false);
      });
  }, [date]);

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
          <p className='prose'>
            {response?.effective ? (
              <FormattedMessage
                id='privacy_policy.last_updated'
                defaultMessage='Last updated {date}'
                values={{
                  date: (
                    <FormattedDate
                      value={response.effective_date}
                      year='numeric'
                      month='short'
                      day='2-digit'
                    />
                  ),
                }}
              />
            ) : (
              <FormattedMessage
                id='terms_of_service.effective_as_of'
                defaultMessage='Effective as of {date}'
                values={{
                  date: (
                    <FormattedDate
                      value={response?.effective_date}
                      year='numeric'
                      month='short'
                      day='2-digit'
                    />
                  ),
                }}
              />
            )}

            {response?.succeeded_by && (
              <>
                {' · '}
                <Link to={`/terms-of-service/${response.succeeded_by}`}>
                  <FormattedMessage
                    id='terms_of_service.upcoming_changes_on'
                    defaultMessage='Upcoming changes on {date}'
                    values={{
                      date: (
                        <FormattedDate
                          value={response.succeeded_by}
                          year='numeric'
                          month='short'
                          day='2-digit'
                        />
                      ),
                    }}
                  />
                </Link>
              </>
            )}
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
