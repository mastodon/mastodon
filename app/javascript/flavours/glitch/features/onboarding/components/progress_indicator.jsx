import PropTypes from 'prop-types';
import { Fragment } from 'react';

import classNames from 'classnames';

import { ReactComponent as CheckIcon } from '@material-symbols/svg-600/outlined/done.svg';

import { Icon }  from 'flavours/glitch/components/icon';


const ProgressIndicator = ({ steps, completed }) => (
  <div className='onboarding__progress-indicator'>
    {(new Array(steps)).fill().map((_, i) => (
      <Fragment key={i}>
        {i > 0 && <div className={classNames('onboarding__progress-indicator__line', { active: completed > i })} />}

        <div className={classNames('onboarding__progress-indicator__step', { active: completed > i })}>
          {completed > i && <Icon icon={CheckIcon} />}
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
