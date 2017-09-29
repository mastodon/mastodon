/*

`<StatusPrepend>`
=================

Originally a part of `<Status>`, but extracted into a separate
component for better documentation and maintainance by
@kibi@glitch.social as a part of glitch-soc/mastodon.

*/

                            /* * * * */

/*

Imports:
--------

*/

//  Package imports  //
import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage } from 'react-intl';

                            /* * * * */

/*

The `<StatusPrepend>` component:
--------------------------------

The `<StatusPrepend>` component holds a status's prepend, ie the text
that says “X reblogged this,” etc. It is represented by an `<aside>`
element.

###  Props

 -  __`type` (`PropTypes.string`) :__
    The type of prepend. One of `'reblogged_by'`, `'reblog'`,
    `'favourite'`.

 -  __`account` (`ImmutablePropTypes.map`) :__
    The account associated with the prepend.

 -  __`parseClick` (`PropTypes.func.isRequired`) :__
    Our click parsing function.

*/

export default class StatusPrepend extends React.PureComponent {

  static propTypes = {
    type: PropTypes.string.isRequired,
    account: ImmutablePropTypes.map.isRequired,
    parseClick: PropTypes.func.isRequired,
    notificationId: PropTypes.number,
  };

/*

###  Implementation

####  `handleClick()`.

This is just a small wrapper for `parseClick()` that gets fired when
an account link is clicked.

*/

  handleClick = (e) => {
    const { account, parseClick } = this.props;
    parseClick(e, `/accounts/${+account.get('id')}`);
  }

/*

####  `<Message>`.

`<Message>` is a quick functional React component which renders the
actual prepend message based on our provided `type`. First we create a
`link` for the account's name, and then use `<FormattedMessage>` to
generate the message.

*/

  Message = () => {
    const { type, account } = this.props;
    let link = (
      <a
        onClick={this.handleClick}
        href={account.get('url')}
        className='status__display-name'
      >
        <b
          dangerouslySetInnerHTML={{
            __html : account.get('display_name_html') || account.get('username'),
          }}
        />
      </a>
    );
    switch (type) {
    case 'reblogged_by':
      return (
        <FormattedMessage
          id='status.reblogged_by'
          defaultMessage='{name} boosted'
          values={{ name : link }}
        />
      );
    case 'favourite':
      return (
        <FormattedMessage
          id='notification.favourite'
          defaultMessage='{name} favourited your status'
          values={{ name : link }}
        />
      );
    case 'reblog':
      return (
        <FormattedMessage
          id='notification.reblog'
          defaultMessage='{name} boosted your status'
          values={{ name : link }}
        />
      );
    }
    return null;
  }

/*

####  `render()`.

Our `render()` is incredibly simple; we just render the icon and then
the `<Message>` inside of an <aside>.

*/

  render () {
    const { Message } = this;
    const { type } = this.props;

    return !type ? null : (
      <aside className={type === 'reblogged_by' ? 'status__prepend' : 'notification__message'}>
        <div className={type === 'reblogged_by' ? 'status__prepend-icon-wrapper' : 'notification__favourite-icon-wrapper'}>
          <i
            className={`fa fa-fw fa-${
              type === 'favourite' ? 'star star-icon' : 'retweet'
            } status__prepend-icon`}
          />
        </div>
        <Message />
      </aside>
    );
  }

}
