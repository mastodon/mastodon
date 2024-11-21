import { FormattedMessage, FormattedNumber } from 'react-intl';

import { Sparklines, SparklinesCurve } from 'react-sparklines';

import { ShortNumber } from 'mastodon/components/short_number';
import type { TimeSeriesMonth } from 'mastodon/models/annual_report';

export const Followers: React.FC<{
  data: TimeSeriesMonth[];
  total?: number;
}> = ({ data, total }) => {
  const change = data.reduce((sum, item) => sum + item.followers, 0);

  const cumulativeGraph = data.reduce(
    (newData, item) => [
      ...newData,
      item.followers + (newData[newData.length - 1] ?? 0),
    ],
    [0],
  );

  return (
    <div className='annual-report__bento__box annual-report__summary__followers'>
      <Sparklines data={cumulativeGraph} margin={0}>
        <svg>
          <defs>
            <linearGradient id='gradient' x1='0%' y1='0%' x2='0%' y2='100%'>
              <stop
                offset='0%'
                stopColor='var(--sparkline-gradient-top)'
                stopOpacity='1'
              />
              <stop
                offset='100%'
                stopColor='var(--sparkline-gradient-bottom)'
                stopOpacity='0'
              />
            </linearGradient>
          </defs>
        </svg>

        <SparklinesCurve style={{ fill: 'none' }} />
      </Sparklines>

      <div className='annual-report__summary__followers__foreground'>
        <div className='annual-report__summary__followers__number'>
          {change > -1 ? '+' : '-'}
          <FormattedNumber value={change} />
        </div>

        <div className='annual-report__summary__followers__label'>
          <span>
            <FormattedMessage
              id='annual_report.summary.followers.followers'
              defaultMessage='followers'
            />
          </span>
          <div className='annual-report__summary__followers__footnote'>
            <FormattedMessage
              id='annual_report.summary.followers.total'
              defaultMessage='{count} total'
              values={{ count: <ShortNumber value={total ?? 0} /> }}
            />
          </div>
        </div>
      </div>
    </div>
  );
};
