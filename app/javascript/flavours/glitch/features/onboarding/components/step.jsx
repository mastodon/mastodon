import PropTypes from 'prop-types';

import { Link } from 'react-router-dom';

import ArrowRightAltIcon from '@/material-icons/400-24px/arrow_right_alt.svg?react';
import CheckIcon from '@/material-icons/400-24px/done.svg?react';
import { Icon } from 'flavours/glitch/components/icon';


export const Step = ({ label, description, icon, iconComponent, completed, onClick, href, to }) => {
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
  } else if (to) {
    return (
      <Link to={to} className='onboarding__steps__item'>
        {content}
      </Link>
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
  to: PropTypes.string,
  onClick: PropTypes.func,
};
