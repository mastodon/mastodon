import { FormattedMessage } from 'react-intl';

import { ShortNumber } from 'flavours/glitch/components/short_number';

interface Props {
  tag: {
    name: string;
    url?: string;
    history?: {
      uses: number;
      accounts: string;
      day: string;
    }[];
    following?: boolean;
    type: 'hashtag';
  };
}

export const AutosuggestHashtag: React.FC<Props> = ({ tag }) => {
  const weeklyUses = tag.history && (
    <ShortNumber
      value={tag.history.reduce((total, day) => total + day.uses * 1, 0)}
    />
  );

  return (
    <div className='autosuggest-hashtag'>
      <div className='autosuggest-hashtag__name'>
        #<strong>{tag.name}</strong>
      </div>
      {tag.history !== undefined && (
        <div className='autosuggest-hashtag__uses'>
          <FormattedMessage
            id='autosuggest_hashtag.per_week'
            defaultMessage='{count} per week'
            values={{ count: weeklyUses }}
          />
        </div>
      )}
    </div>
  );
};
