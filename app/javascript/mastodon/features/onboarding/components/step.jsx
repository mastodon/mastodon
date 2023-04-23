import React from 'react';
import PropTypes from 'prop-types';
import Icon from 'mastodon/components/icon';
import Check from 'mastodon/components/check';

const Step = ({ label, description, icon, completed, onClick, href }) => {
  const content = (
    <>
      <div className='onboarding__steps__item__icon'>
        <Icon id={icon} />
      </div>

      <div className='onboarding__steps__item__description'>
        <h6>{label}</h6>
        <p>{description}</p>
      </div>

      {completed && (
        <div className='onboarding__steps__item__progress'>
          <Check />
        </div>
      )}
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
  completed: PropTypes.bool,
  href: PropTypes.string,
  onClick: PropTypes.func,
};

export default Step;