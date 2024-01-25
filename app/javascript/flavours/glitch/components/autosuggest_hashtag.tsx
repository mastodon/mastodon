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

export const AutosuggestHashtag: React.FC<Props> = ({ tag }) => (
  <div className='autosuggest-hashtag'>
    <div className='autosuggest-hashtag__name'>
      #<strong>{tag.name}</strong>
    </div>

    {tag.history !== undefined && (
      <div className='autosuggest-hashtag__uses'>
        <ShortNumber
          value={tag.history.reduce((total, day) => total + day.uses * 1, 0)}
        />
      </div>
    )}
  </div>
);
