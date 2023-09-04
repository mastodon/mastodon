import React from 'react';
import PropTypes from 'prop-types';
import ShortNumber from 'mastodon/components/short_number';
import { FormattedMessage } from 'react-intl';

export default class AutosuggestHashtag extends React.PureComponent {

  static propTypes = {
    tag: PropTypes.shape({
      name: PropTypes.string.isRequired,
      url: PropTypes.string,
      history: PropTypes.array,
    }).isRequired,
  };

  render() {
    const { tag } = this.props;
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
  }

}
