/*

`<AccountHeader>`
=================

>   For more information on the contents of this file, please contact:
>
>   - kibigo! [@kibi@glitch.social]

Original file by @gargron@mastodon.social et al as part of
tootsuite/mastodon. We've expanded it in order to handle user bio
frontmatter.

The `<AccountHeader>` component provides the header for account
timelines. It is a fairly simple component which mostly just consists
of a `render()` method.

__Props:__

 -  __`account` (`ImmutablePropTypes.map`) :__
    The account to render a header for.

 -  __`me` (`PropTypes.number.isRequired`) :__
    The id of the currently-signed-in account.

 -  __`onFollow` (`PropTypes.func.isRequired`) :__
    The function to call when the user clicks the "follow" button.

 -  __`intl` (`PropTypes.object.isRequired`) :__
    Our internationalization object, inserted by `@injectIntl`.

*/

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

Imports:
--------

*/

//  Package imports  //
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';

//  Mastodon imports  //
import emojify from '../../../mastodon/features/emoji/emoji';
import IconButton from '../../../mastodon/components/icon_button';
import Avatar from '../../../mastodon/components/avatar';
import { me } from '../../../mastodon/initial_state';

//  Our imports  //
import { processBio } from '../../util/bio_metadata';

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

Inital setup:
-------------

The `messages` constant is used to define any messages that we need
from inside props. In our case, these are the `unfollow`, `follow`, and
`requested` messages used in the `title` of our buttons.

*/

const messages = defineMessages({
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  requested: { id: 'account.requested', defaultMessage: 'Awaiting approval' },
});

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

Implementation:
---------------

*/

@injectIntl
export default class AccountHeader extends ImmutablePureComponent {

  static propTypes = {
    account  : ImmutablePropTypes.map,
    onFollow : PropTypes.func.isRequired,
    intl     : PropTypes.object.isRequired,
  };

/*

###  `render()`

The `render()` function is used to render our component.

*/

  render () {
    const { account, intl } = this.props;

/*

If no `account` is provided, then we can't render a header. Otherwise,
we get the `displayName` for the account, if available. If it's blank,
then we set the `displayName` to just be the `username` of the account.

*/

    if (!account) {
      return null;
    }

    let displayName = account.get('display_name_html');
    let info        = '';
    let actionBtn   = '';
    let following   = false;

/*

Next, we handle the account relationships. If the account follows the
user, then we add an `info` message. If the user has requested a
follow, then we disable the `actionBtn` and display an hourglass.
Otherwise, if the account isn't blocked, we set the `actionBtn` to the
appropriate icon.

*/

    if (me !== account.get('id')) {
      if (account.getIn(['relationship', 'followed_by'])) {
        info = (
          <span className='account--follows-info'>
            <FormattedMessage id='account.follows_you' defaultMessage='Follows you' />
          </span>
        );
      }
      if (account.getIn(['relationship', 'requested'])) {
        actionBtn = (
          <div className='account--action-button'>
            <IconButton size={26} disabled icon='hourglass' title={intl.formatMessage(messages.requested)} />
          </div>
        );
      } else if (!account.getIn(['relationship', 'blocking'])) {
        following = account.getIn(['relationship', 'following']);
        actionBtn = (
          <div className='account--action-button'>
            <IconButton
              size={26}
              icon={following ? 'user-times' : 'user-plus'}
              active={following ? true : false}
              title={intl.formatMessage(following ? messages.unfollow : messages.follow)}
              onClick={this.props.onFollow}
            />
          </div>
        );
      }
    }

/*
 we extract the `text` and
`metadata` from our account's `note` using `processBio()`.

*/

    const { text, metadata } = processBio(account.get('note'));

/*

Here, we render our component using all the things we've defined above.

*/

    return (
      <div className='account__header__wrapper'>
        <div
          className='account__header'
          style={{ backgroundImage: `url(${account.get('header')})` }}
        >
          <div>
            <a href={account.get('url')} target='_blank' rel='noopener'>
              <span className='account__header__avatar'>
                <Avatar account={account} size={90} />
              </span>
              <span
                className='account__header__display-name'
                dangerouslySetInnerHTML={{ __html: displayName }}
              />
            </a>
            <span className='account__header__username'>
              @{account.get('acct')}
              {account.get('locked') ? <i className='fa fa-lock' /> : null}
            </span>
            <div className='account__header__content' dangerouslySetInnerHTML={{ __html: emojify(text) }} />

            {info}
            {actionBtn}
          </div>
        </div>

        {metadata.length && (
          <table className='account__metadata'>
            <tbody>
              {(() => {
                let data = [];
                for (let i = 0; i < metadata.length; i++) {
                  data.push(
                    <tr key={i}>
                      <th scope='row'><div dangerouslySetInnerHTML={{ __html: emojify(metadata[i][0]) }} /></th>
                      <td><div dangerouslySetInnerHTML={{ __html: emojify(metadata[i][1]) }} /></td>
                    </tr>
                  );
                }
                return data;
              })()}
            </tbody>
          </table>
        ) || null}
      </div>
    );
  }

}
