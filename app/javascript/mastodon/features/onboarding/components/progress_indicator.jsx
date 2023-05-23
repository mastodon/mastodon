import PropTypes from 'prop-types';
import { Fragment } from 'react';

import classNames from 'classnames';

import { Check } from 'mastodon/components/check';

const ProgressIndicator = ({ steps, completed }) => (
  <div className='onboarding__progress-indicator'>
    {(new Array(steps)).fill().map((_, i) => (
      <Fragment key={i}>
        {i > 0 && <div className={classNames('onboarding__progress-indicator__line', { active: completed > i })} />}

        <div className={classNames('onboarding__progress-indicator__step', { active: completed > i })}>
          {completed > i && <Check />}
        </div>
      </Fragment>
    ))}
  </div>
);

ProgressIndicator.propTypes = {
  steps: PropTypes.number.isRequired,
  completed: PropTypes.number,
};

export default ProgressIndicator;
