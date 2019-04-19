//  Package imports.
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import {
  FormattedMessage,
  defineMessages,
} from 'react-intl';

//  Components.
import Avatar from 'flavours/glitch/components/avatar';
import Permalink from 'flavours/glitch/components/permalink';

//  Utils.
import { hiddenComponent } from 'flavours/glitch/util/react_helpers';
import { profileLink } from 'flavours/glitch/util/backend_links';

//  Messages.
const messages = defineMessages({
  edit: {
    defaultMessage: 'Edit profile',
    id: 'navigation_bar.edit_profile',
  },
});

//  The component.
export default function DrawerAccount ({ account }) {

  //  We need an account to render.
  if (!account) {
    return (
      <div className='drawer--account'>
        { profileLink !== undefined && (
          <a
            className='edit'
            href={ profileLink }
          >
            <FormattedMessage {...messages.edit} />
          </a>
        )}
      </div>
    );
  }

  //  The result.
  return (
    <div className='drawer--account'>
      <Permalink
        className='avatar'
        href={account.get('url')}
        to={`/accounts/${account.get('id')}`}
      >
        <span {...hiddenComponent}>{account.get('acct')}</span>
        <Avatar
          account={account}
          size={40}
        />
      </Permalink>
      <Permalink
        className='acct'
        href={account.get('url')}
        to={`/accounts/${account.get('id')}`}
      >
        <strong>@{account.get('acct')}</strong>
      </Permalink>
      { profileLink !== undefined && (
        <a
          className='edit'
          href={ profileLink }
        ><FormattedMessage {...messages.edit} /></a>
      )}
    </div>
  );
}

//  Props.
DrawerAccount.propTypes = { account: ImmutablePropTypes.map };
