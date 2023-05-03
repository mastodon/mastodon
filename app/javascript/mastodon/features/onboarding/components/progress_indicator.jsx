import React from 'react';
import PropTypes from 'prop-types';
import Check from 'mastodon/components/check';
import classNames from 'classnames';

const ProgressIndicator = ({ steps, completed }) => (
  <div className='onboarding__progress-indicator'>
    {(new Array(steps)).fill().map((_, i) => (
      <React.Fragment key={i}>
        {i > 0 && <div className={classNames('onboarding__progress-indicator__line', { active: completed > i })} />}

        <div className={classNames('onboarding__progress-indicator__step', { active: completed > i })}>
          {completed > i && <Check />}
        </div>
      </React.Fragment>
    ))}
  </div>
);

ProgressIndicator.propTypes = {
  steps: PropTypes.number.isRequired,
  completed: PropTypes.number,
};

export default ProgressIndicator;