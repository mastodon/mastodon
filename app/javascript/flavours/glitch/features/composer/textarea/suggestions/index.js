//  Package imports.
import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';

//  Components.
import ComposerTextareaSuggestionsItem from './item';

//  The component.
export default function ComposerTextareaSuggestions ({
  hidden,
  onSuggestionClick,
  suggestions,
  value,
}) {

  //  The result.
  return (
    <div
      className='composer--textarea--suggestions'
      hidden={hidden || !suggestions || suggestions.isEmpty()}
    >
      {!hidden && suggestions ? suggestions.map(
        (suggestion, index) => (
          <ComposerTextareaSuggestionsItem
            index={index}
            key={typeof suggestion === 'object' ? suggestion.id : suggestion}
            onClick={onSuggestionClick}
            selected={index === value}
            suggestion={suggestion}
          />
        )
      ) : null}
    </div>
  );
}

ComposerTextareaSuggestions.propTypes = {
  hidden: PropTypes.bool,
  onSuggestionClick: PropTypes.func,
  suggestions: ImmutablePropTypes.list,
  value: PropTypes.number,
};
