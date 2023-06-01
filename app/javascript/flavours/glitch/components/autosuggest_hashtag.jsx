import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

import ShortNumber from 'flavours/glitch/components/short_number';

export default class AutosuggestHashtag extends PureComponent {

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
