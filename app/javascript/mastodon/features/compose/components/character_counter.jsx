import PropTypes from 'prop-types';

import { length } from 'stringz';

export const CharacterCounter = ({ text, max }) => {
  const diff = max - length(text);

  if (diff < 0) {
    return <span className='character-counter character-counter--over'>{diff}</span>;
  }

  return <span className='character-counter'>{diff}</span>;
};

CharacterCounter.propTypes = {
  text: PropTypes.string.isRequired,
  max: PropTypes.number.isRequired,
};
