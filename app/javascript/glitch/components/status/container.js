/*

`<StatusContainer>`
===================

Original file by @gargron@mastodon.social et al as part of
tootsuite/mastodon. Documentation by @kibi@glitch.social. The code
detecting reblogs has been moved here from <Status>.

*/

                            /* * * * */

/*

Imports:
--------

*/

//  Package imports  //
import React from 'react';
import { connect } from 'react-redux';
import {
  defineMessages,
  injectIntl,
  FormattedMessage,
} from 'react-intl';

//  Mastodon imports  //
import { makeGetStatus } from '../../../mastodon/selectors';
import {
  replyCompose,
  mentionCompose,
} from '../../../mastodon/actions/compose';
import {
  reblog,
  favourite,
  unreblog,
  unfavourite,
  pin,
  unpin,
} from '../../../mastodon/actions/interactions';
import { blockAccount } from '../../../mastodon/actions/accounts';
import { initMuteModal } from '../../../mastodon/actions/mutes';
import {
  muteStatus,
  unmuteStatus,
  deleteStatus,
} from '../../../mastodon/actions/statuses';
import { initReport } from '../../../mastodon/actions/reports';
import { openModal } from '../../../mastodon/actions/modal';

//  Our imports  //
import Status from '.';

                            /* * * * */

/*

Inital setup:
-------------

The `messages` constant is used to define any messages that we will
need in our component. In our case, these are the various confirmation
messages used with statuses.

*/

const messages = defineMessages({
  deleteConfirm : {
    id             : 'confirmations.delete.confirm',
    defaultMessage : 'Delete',
  },
  deleteMessage : {
    id             : 'confirmations.delete.message',
    defaultMessage : 'Are you sure you want to delete this status?',
  },
  blockConfirm  : {
    id             : 'confirmations.block.confirm',
    defaultMessage : 'Block',
  },
});

                            /* * * * */

/*

State mapping:
--------------

The `mapStateToProps()` function maps various state properties to the
props of our component. We wrap this in a `makeMapStateToProps()`
function to give us closure and preserve `getStatus()` across function
calls.

*/

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();

  const mapStateToProps = (state, ownProps) => {

    let status = getStatus(state, ownProps.id);

    if(status === null) {
      console.error(`ERROR! NULL STATUS! ${ownProps.id}`);
      // work-around: find first good status
      for (let k of state.get('statuses').keys()) {
        status = getStatus(state, k);
        if (status !== null) break;
      }
    }

    let reblogStatus = status.get('reblog', null);
    let account = undefined;
    let prepend = undefined;

/*

Here we process reblogs. If our status is a reblog, then we create a
`prependMessage` to pass along to our `<Status>` along with the
reblogger's `account`, and set `coreStatus` (the one we will actually
render) to the status which has been reblogged.

*/

    if (reblogStatus !== null && typeof reblogStatus === 'object') {
      account = status.get('account');
      status = reblogStatus;
      prepend = 'reblogged_by';
    }

/*

Here are the props we pass to `<Status>`.

*/

    return {
      status      : status,
      account     : account || ownProps.account,
      settings    : state.get('local_settings'),
      prepend     : prepend || ownProps.prepend,
      reblogModal : state.getIn(['meta', 'boost_modal']),
      deleteModal : state.getIn(['meta', 'delete_modal']),
    };
  };

  return mapStateToProps;
};

                            /* * * * */

/*

Dispatch mapping:
-----------------

The `mapDispatchToProps()` function maps dispatches to our store to the
various props of our component. We need to provide dispatches for all
of the things you can do with a status: reply, reblog, favourite, et
cetera.

For a few of these dispatches, we open up confirmation modals; the rest
just immediately execute their corresponding actions.

*/

const mapDispatchToProps = (dispatch, { intl }) => ({

  onReply (status, router) {
    dispatch(replyCompose(status, router));
  },

  onModalReblog (status) {
    dispatch(reblog(status));
  },

  onReblog (status, e) {
    if (status.get('reblogged')) {
      dispatch(unreblog(status));
    } else {
      if (e.shiftKey || !this.reblogModal) {
        this.onModalReblog(status);
      } else {
        dispatch(openModal('BOOST', { status, onReblog: this.onModalReblog }));
      }
    }
  },

  onFavourite (status) {
    if (status.get('favourited')) {
      dispatch(unfavourite(status));
    } else {
      dispatch(favourite(status));
    }
  },

  onPin (status) {
    if (status.get('pinned')) {
      dispatch(unpin(status));
    } else {
      dispatch(pin(status));
    }
  },

  onEmbed (status) {
    dispatch(openModal('EMBED', { url: status.get('url') }));
  },

  onDelete (status) {
    if (!this.deleteModal) {
      dispatch(deleteStatus(status.get('id')));
    } else {
      dispatch(openModal('CONFIRM', {
        message: intl.formatMessage(messages.deleteMessage),
        confirm: intl.formatMessage(messages.deleteConfirm),
        onConfirm: () => dispatch(deleteStatus(status.get('id'))),
      }));
    }
  },

  onMention (account, router) {
    dispatch(mentionCompose(account, router));
  },

  onOpenMedia (media, index) {
    dispatch(openModal('MEDIA', { media, index }));
  },

  onOpenVideo (media, time) {
    dispatch(openModal('VIDEO', { media, time }));
  },

  onBlock (account) {
    dispatch(openModal('CONFIRM', {
      message: <FormattedMessage id='confirmations.block.message' defaultMessage='Are you sure you want to block {name}?' values={{ name: <strong>@{account.get('acct')}</strong> }} />,
      confirm: intl.formatMessage(messages.blockConfirm),
      onConfirm: () => dispatch(blockAccount(account.get('id'))),
    }));
  },

  onReport (status) {
    dispatch(initReport(status.get('account'), status));
  },

  onMute (account) {
    dispatch(initMuteModal(account));
  },

  onMuteConversation (status) {
    if (status.get('muted')) {
      dispatch(unmuteStatus(status.get('id')));
    } else {
      dispatch(muteStatus(status.get('id')));
    }
  },
});

export default injectIntl(
  connect(makeMapStateToProps, mapDispatchToProps)(Status)
);
