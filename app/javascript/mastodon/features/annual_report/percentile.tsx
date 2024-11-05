/* eslint-disable react/jsx-no-useless-fragment */
import { FormattedMessage, FormattedNumber } from 'react-intl';

import type { Percentiles } from 'mastodon/models/annual_report';

export const Percentile: React.FC<{
  data: Percentiles;
}> = ({ data }) => {
  const percentile = data.statuses;

  return (
    <div className='annual-report__bento__box annual-report__summary__percentile'>
      <FormattedMessage
        id='annual_report.summary.percentile.text'
        defaultMessage='<topLabel>That puts you in the top</topLabel><percentage></percentage><bottomLabel>of Mastodon users.</bottomLabel>'
        values={{
          topLabel: (str) => (
            <div className='annual-report__summary__percentile__label'>
              {str}
            </div>
          ),
          percentage: () => (
            <div className='annual-report__summary__percentile__number'>
              <FormattedNumber
                value={percentile / 100}
                style='percent'
                maximumFractionDigits={1}
              />
            </div>
          ),
          bottomLabel: (str) => (
            <div>
              <div className='annual-report__summary__percentile__label'>
                {str}
              </div>

              {percentile < 6 && (
                <div className='annual-report__summary__percentile__footnote'>
                  <FormattedMessage
                    id='annual_report.summary.percentile.we_wont_tell_bernie'
                    defaultMessage="We won't tell Bernie."
                  />
                </div>
              )}
            </div>
          ),
        }}
      >
        {(message) => <>{message}</>}
      </FormattedMessage>
    </div>
  );
};
