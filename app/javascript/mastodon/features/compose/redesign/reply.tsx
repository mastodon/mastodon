import { Link } from 'react-router-dom';

import { Avatar } from '@/mastodon/components/avatar';
import { LinkedDisplayName } from '@/mastodon/components/display_name';
import { EmojiHTML } from '@/mastodon/components/emoji/html';
import { RelativeTimestamp } from '@/mastodon/components/relative_timestamp';
import { useHandlersForStatus } from '@/mastodon/components/status/hooks';
import { selectAccountStatus } from '@/mastodon/selectors/statuses';
import { useAppSelector } from '@/mastodon/store';

import classes from './styles.module.scss';

export const ComposeReply: React.FC = () => {
  const replyId = useAppSelector(
    (state) => state.compose.get('in_reply_to') as null | string,
  );
  const status = useAppSelector((state) => selectAccountStatus(state, replyId));

  const htmlHandlers = useHandlersForStatus(status);

  if (!status) {
    return;
  }

  return (
    <figure className={classes.reply}>
      <figcaption className={classes.replyAccount}>
        <Avatar
          account={status.account}
          className={classes.replyAvatar}
          withLink
        />
        <LinkedDisplayName
          displayProps={{ account: status.account, variant: 'simple' }}
        />
        <span className={classes.replyTime}>
          &middot;&nbsp;
          <Link to={`/@${status.account.acct}/${status.id}`}>
            <RelativeTimestamp timestamp={status.created_at} />
          </Link>
        </span>
      </figcaption>

      <EmojiHTML
        as='blockquote'
        cite={status.uri}
        htmlString={status.translation?.contentHtml ?? status.contentHtml}
        extraEmojis={status.emojis}
        className={classes.replyText}
        lang={status.translation?.language ?? status.language}
        {...htmlHandlers}
      />
    </figure>
  );
};
