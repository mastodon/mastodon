import { createAppSelector } from 'mastodon/store';

export const getAncestorsIds = createAppSelector(
  [(_, id: string) => id, (state) => state.contexts.inReplyTos],
  (statusId, inReplyTos) => {
    const ancestorsIds: string[] = [];

    let currentId: string | undefined = statusId;

    while (currentId && !ancestorsIds.includes(currentId)) {
      ancestorsIds.unshift(currentId);
      currentId = inReplyTos[currentId];
    }

    return ancestorsIds;
  },
);

export const getDescendantsIds = createAppSelector(
  [
    (_, id: string) => id,
    (state) => state.contexts.replies,
    (state) => state.statuses,
  ],
  (statusId, contextReplies, statuses) => {
    const descendantsIds: string[] = [];

    const visitIds = [statusId];

    while (visitIds.length > 0) {
      const id = visitIds.pop();

      if (!id) {
        break;
      }

      const replies = contextReplies[id];

      if (statusId !== id) {
        descendantsIds.push(id);
      }

      if (replies) {
        replies.toReversed().forEach((replyId) => {
          if (
            !visitIds.includes(replyId) &&
            !descendantsIds.includes(replyId) &&
            statusId !== replyId
          ) {
            visitIds.push(replyId);
          }
        });
      }
    }

    let insertAt = descendantsIds.findIndex((id) => {
      const status = statuses.get(id);

      if (!status) {
        return false;
      }

      const inReplyToAccountId = status.get('in_reply_to_account_id') as
        | string
        | null;
      const accountId = status.get('account') as string;

      return inReplyToAccountId !== accountId;
    });

    if (insertAt !== -1) {
      descendantsIds.forEach((id, idx) => {
        const status = statuses.get(id);

        if (!status) {
          return;
        }

        const inReplyToAccountId = status.get('in_reply_to_account_id') as
          | string
          | null;
        const accountId = status.get('account') as string;

        if (idx > insertAt && inReplyToAccountId === accountId) {
          descendantsIds.splice(idx, 1);
          descendantsIds.splice(insertAt, 0, id);
          insertAt += 1;
        }
      });
    }

    return descendantsIds;
  },
);
