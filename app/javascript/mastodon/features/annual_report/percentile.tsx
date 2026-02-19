/* eslint-disable react/jsx-no-useless-fragment */
import { FormattedMessage, FormattedNumber } from 'react-intl';

import { domain } from 'mastodon/initial_state';
import type { Percentiles } from 'mastodon/models/annual_report';

export const Percentile: React.FC<{
  data: Percentiles;
}> = ({ data }) => {
  const percentile = data.statuses;

  return (
    <div className='annual-report__bento__box annual-report__summary__percentile'>
      <FormattedMessage
        id='annual_report.summary.percentile.text'
        defaultMessage='<topLabel>That puts you in the top</topLabel><percentage></percentage><bottomLabel>of {domain} users.</bottomLabel>'
        values={{
          topLabel: (str) => (
            <div className='annual-report__summary__percentile__label'>
              {str}
            </div>
          ),
          percentage: () => (
            <div className='annual-report__summary__percentile__number'>
              <FormattedNumber
                value={Math.min(percentile, 99) / 100}
                style='percent'
                maximumFractionDigits={percentile < 1 ? 1 : 0}
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

          domain,
        }}
      >
        {(message) => <>{message}</>}
      </FormattedMessage>
    </div>
  );
};
