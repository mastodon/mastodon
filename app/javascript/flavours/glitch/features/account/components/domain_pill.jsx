import PropTypes from 'prop-types';
import { useState, useRef, useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import Overlay from 'react-overlays/Overlay';



import AlternateEmailIcon from '@/material-icons/400-24px/alternate_email.svg?react';
import BadgeIcon from '@/material-icons/400-24px/badge.svg?react';
import GlobeIcon from '@/material-icons/400-24px/globe.svg?react';
import { Icon } from 'flavours/glitch/components/icon';

export const DomainPill = ({ domain, username, isSelf }) => {
  const [open, setOpen] = useState(false);
  const [expanded, setExpanded] = useState(false);
  const triggerRef = useRef(null);

  const handleClick = useCallback(() => {
    setOpen(!open);
  }, [open, setOpen]);

  const handleExpandClick = useCallback(() => {
    setExpanded(!expanded);
  }, [expanded, setExpanded]);

  return (
    <>
      <button className={classNames('account__domain-pill', { active: open })} ref={triggerRef} onClick={handleClick}>{domain}</button>

      <Overlay show={open} rootClose onHide={handleClick} offset={[5, 5]} target={triggerRef}>
        {({ props }) => (
          <div {...props} className='account__domain-pill__popout dropdown-animation'>
            <div className='account__domain-pill__popout__header'>
              <div className='account__domain-pill__popout__header__icon'><Icon icon={BadgeIcon} /></div>
              <h3><FormattedMessage id='domain_pill.whats_in_a_handle' defaultMessage="What's in a handle?" /></h3>
            </div>

            <div className='account__domain-pill__popout__handle'>
              <div className='account__domain-pill__popout__handle__label'>{isSelf ? <FormattedMessage id='domain_pill.your_handle' defaultMessage='Your handle:' /> : <FormattedMessage id='domain_pill.their_handle' defaultMessage='Their handle:' />}</div>
              <div className='account__domain-pill__popout__handle__handle'>@{username}@{domain}</div>
            </div>

            <div className='account__domain-pill__popout__parts'>
              <div>
                <div className='account__domain-pill__popout__parts__icon'><Icon icon={AlternateEmailIcon} /></div>

                <div>
                  <h6><FormattedMessage id='domain_pill.username' defaultMessage='Username' /></h6>
                  <p>{isSelf ? <FormattedMessage id='domain_pill.your_username' defaultMessage='Your unique identifier on this server. It’s possible to find users with the same username on different servers.' /> : <FormattedMessage id='domain_pill.their_username' defaultMessage='Their unique identifier on their server. It’s possible to find users with the same username on different servers.' />}</p>
                </div>
              </div>

              <div>
                <div className='account__domain-pill__popout__parts__icon'><Icon icon={GlobeIcon} /></div>

                <div>
                  <h6><FormattedMessage id='domain_pill.server' defaultMessage='Server' /></h6>
                  <p>{isSelf ? <FormattedMessage id='domain_pill.your_server' defaultMessage='Your digital home, where all of your posts live. Don’t like this one? Transfer servers at any time and bring your followers, too.' /> : <FormattedMessage id='domain_pill.their_server' defaultMessage='Their digital home, where all of their posts live.' />}</p>
                </div>
              </div>
            </div>

            <p>{isSelf ? <FormattedMessage id='domain_pill.who_you_are' defaultMessage='Because your handle says who you are and where you are, people can interact with you across the social web of <button>ActivityPub-powered platforms</button>.' values={{ button: x => <button onClick={handleExpandClick} className='link-button'>{x}</button> }} /> : <FormattedMessage id='domain_pill.who_they_are' defaultMessage='Since handles say who someone is and where they are, you can interact with people across the social web of <button>ActivityPub-powered platforms</button>.' values={{ button: x => <button onClick={handleExpandClick} className='link-button'>{x}</button> }} />}</p>

            {expanded && (
              <>
                <p><FormattedMessage id='domain_pill.activitypub_like_language' defaultMessage='ActivityPub is like the language Mastodon speaks with other social networks.' /></p>
                <p><FormattedMessage id='domain_pill.activitypub_lets_connect' defaultMessage='It lets you connect and interact with people not just on Mastodon, but across different social apps too.' /></p>
              </>
            )}
          </div>
        )}
      </Overlay>
    </>
  );
};

DomainPill.propTypes = {
  username: PropTypes.string.isRequired,
  domain: PropTypes.string.isRequired,
  isSelf: PropTypes.bool,
};
