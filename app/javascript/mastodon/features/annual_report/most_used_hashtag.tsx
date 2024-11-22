import { FormattedMessage } from 'react-intl';

import type { NameAndCount } from 'mastodon/models/annual_report';

export const MostUsedHashtag: React.FC<{
  data: NameAndCount[];
}> = ({ data }) => {
  const hashtag = data[0];

  return (
    <div className='annual-report__bento__box annual-report__summary__most-used-hashtag'>
      <div className='annual-report__summary__most-used-hashtag__hashtag'>
        {hashtag ? (
          <>#{hashtag.name}</>
        ) : (
          <FormattedMessage
            id='annual_report.summary.most_used_hashtag.none'
            defaultMessage='None'
          />
        )}
      </div>
      <div className='annual-report__summary__most-used-hashtag__label'>
        <FormattedMessage
          id='annual_report.summary.most_used_hashtag.most_used_hashtag'
          defaultMessage='most used hashtag'
        />
      </div>
    </div>
  );
};
