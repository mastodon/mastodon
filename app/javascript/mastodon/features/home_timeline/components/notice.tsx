import { useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import background from 'mastodon/../images/friends-cropped.png';
import type { ApiNoticeJSON } from 'mastodon/actions/notices';
import { dismissNotice } from 'mastodon/actions/notices';
import { IconButton } from 'mastodon/components/icon_button';
import { useAppDispatch } from 'mastodon/store';

const messages = defineMessages({
  dismiss: { id: 'dismissable_banner.dismiss', defaultMessage: 'Dismiss' },
});

interface Props {
  notice: ApiNoticeJSON;
}

export const Notice: React.FC<Props> = ({ notice }) => {
  const intl = useIntl();

  const dispatch = useAppDispatch();

  const handleDismiss = useCallback(() => {
    void dispatch(dismissNotice({ id: notice.id }));
  }, [dispatch, notice.id]);

  return (
    <div className='dismissable-banner'>
      <div className='dismissable-banner__message'>
        <img
          src={notice.icon ?? background}
          alt=''
          className='dismissable-banner__background-image'
        />

        <h1>{notice.title}</h1>

        <p>{notice.message}</p>

        <div className='dismissable-banner__message__wrapper'>
          <div className='dismissable-banner__message__actions'>
            {notice.actions.map((action, i) => (
              <a key={`action-${i}`} href={action.url} className='button'>
                {action.label}
              </a>
            ))}
          </div>
        </div>
      </div>

      <div className='dismissable-banner__action'>
        <IconButton
          icon='times'
          title={intl.formatMessage(messages.dismiss)}
          onClick={handleDismiss}
        />
      </div>
    </div>
  );
};
