import { FormattedMessage } from 'react-intl';

import { createSelector } from '@reduxjs/toolkit';

import { animated, useSpring } from '@react-spring/web';

import { me } from 'mastodon/initial_state';
import { useAppSelector } from 'mastodon/store';
import type { RootState } from 'mastodon/store';
import { HASHTAG_PATTERN_REGEX } from 'mastodon/utils/hashtags';

const selector = createSelector(
  (state: RootState) => state.compose.get('privacy') as string,
  (state: RootState) => !!state.accounts.getIn([me, 'locked']),
  (state: RootState) => state.compose.get('text') as string,
  (privacy, locked, text) => ({
    needsLockWarning: privacy === 'private' && !locked,
    hashtagWarning: privacy !== 'public' && HASHTAG_PATTERN_REGEX.test(text),
    directMessageWarning: privacy === 'direct',
  }),
);

export const Warning = () => {
  const { needsLockWarning, hashtagWarning, directMessageWarning } =
    useAppSelector(selector);
  if (needsLockWarning) {
    return (
      <WarningMessage>
        <FormattedMessage
          id='compose_form.lock_disclaimer'
          defaultMessage='Your account is not {locked}. Anyone can follow you to view your follower-only posts.'
          values={{
            locked: (
              <a href='/settings/privacy#account_unlocked'>
                <FormattedMessage
                  id='compose_form.lock_disclaimer.lock'
                  defaultMessage='locked'
                />
              </a>
            ),
          }}
        />
      </WarningMessage>
    );
  }

  if (hashtagWarning) {
    return (
      <WarningMessage>
        <FormattedMessage
          id='compose_form.hashtag_warning'
          defaultMessage="This post won't be listed under any hashtag as it is unlisted. Only public posts can be searched by hashtag."
        />
      </WarningMessage>
    );
  }

  if (directMessageWarning) {
    return (
      <WarningMessage>
        <FormattedMessage
          id='compose_form.encryption_warning'
          defaultMessage='Posts on Mastodon are not end-to-end encrypted. Do not share any dangerous information over Mastodon.'
        />{' '}
        <a href='/terms' target='_blank'>
          <FormattedMessage
            id='compose_form.direct_message_warning_learn_more'
            defaultMessage='Learn more'
          />
        </a>
      </WarningMessage>
    );
  }

  return null;
};

export const WarningMessage: React.FC<React.PropsWithChildren> = ({
  children,
}) => {
  const styles = useSpring({
    from: {
      opacity: 0,
      transform: 'scale(0.85, 0.75)',
    },
    to: {
      opacity: 1,
      transform: 'scale(1, 1)',
    },
  });
  return (
    <animated.div className='compose-form__warning' style={styles}>
      {children}
    </animated.div>
  );
};
