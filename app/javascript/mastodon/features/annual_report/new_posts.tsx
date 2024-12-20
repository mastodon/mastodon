import { FormattedNumber, FormattedMessage } from 'react-intl';

import ChatBubbleIcon from '@/material-icons/400-24px/chat_bubble.svg?react';
import type { TimeSeriesMonth } from 'mastodon/models/annual_report';

export const NewPosts: React.FC<{
  data: TimeSeriesMonth[];
}> = ({ data }) => {
  const posts = data.reduce((sum, item) => sum + item.statuses, 0);

  return (
    <div className='annual-report__bento__box annual-report__summary__new-posts'>
      <svg width={500} height={500}>
        <defs>
          <pattern
            id='posts'
            x='0'
            y='0'
            width='32'
            height='35'
            patternUnits='userSpaceOnUse'
          >
            <circle cx='12' cy='12' r='12' fill='var(--lime)' />
            <ChatBubbleIcon
              fill='var(--indigo-1)'
              x='4'
              y='4'
              width='16'
              height='16'
            />
          </pattern>
        </defs>

        <rect
          width={500}
          height={500}
          fill='url(#posts)'
          style={{ opacity: 0.2 }}
        />
      </svg>

      <div className='annual-report__summary__new-posts__number'>
        <FormattedNumber value={posts} />
      </div>
      <div className='annual-report__summary__new-posts__label'>
        <FormattedMessage
          id='annual_report.summary.new_posts.new_posts'
          defaultMessage='new posts'
        />
      </div>
    </div>
  );
};
