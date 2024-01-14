import PropTypes from 'prop-types';

import { ReactComponent as ArrowRightAltIcon } from '@material-symbols/svg-600/outlined/arrow_right_alt.svg';
import { ReactComponent as CheckIcon } from '@material-symbols/svg-600/outlined/done.svg';

import { Icon }  from 'flavours/glitch/components/icon';

const Step = ({ label, description, icon, iconComponent, completed, onClick, href }) => {
  const content = (
    <>
      <div className='onboarding__steps__item__icon'>
        <Icon id={icon} icon={iconComponent} />
      </div>

      <div className='onboarding__steps__item__description'>
        <h6>{label}</h6>
        <p>{description}</p>
      </div>

      <div className={completed ? 'onboarding__steps__item__progress' : 'onboarding__steps__item__go'}>
        {completed ? <Icon icon={CheckIcon} /> : <Icon icon={ArrowRightAltIcon} />}
      </div>
    </>
  );

  if (href) {
    return (
      <a href={href} onClick={onClick} target='_blank' rel='noopener' className='onboarding__steps__item'>
        {content}
      </a>
    );
  }

  return (
    <button onClick={onClick} className='onboarding__steps__item'>
      {content}
    </button>
  );
};

Step.propTypes = {
  label: PropTypes.node,
  description: PropTypes.node,
  icon: PropTypes.string,
  iconComponent: PropTypes.func,
  completed: PropTypes.bool,
  href: PropTypes.string,
  onClick: PropTypes.func,
};

export default Step;
