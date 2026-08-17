import { Avatar } from '@/mastodon/components/avatar';
import { DisplayNameSimple } from '@/mastodon/components/display_name/simple';
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
    <blockquote cite={status.uri} className={classes.reply}>
      <cite className={classes.replyAccount}>
        <Avatar account={status.account} className={classes.replyAvatar} />
        <DisplayNameSimple account={status.account} />
        <span className={classes.replyTime}>
          &middot;&nbsp;
          <RelativeTimestamp timestamp={status.created_at} />
        </span>
      </cite>

      <EmojiHTML
        htmlString={status.translation?.contentHtml ?? status.contentHtml}
        extraEmojis={status.emojis}
        className={classes.replyText}
        lang={status.translation?.language ?? status.language}
        {...htmlHandlers}
      />
    </blockquote>
  );
};
