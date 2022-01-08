import React from 'react';
import { FormattedMessage } from 'react-intl';
import Icon from 'mastodon/components/icon';
import SearchUsers from '../../../search_users';

const UsersListCreator = (props) => {
  return (
    <div className="search-results__section">
      <h5>
        <Icon id="users" fixedWidth />
        <FormattedMessage
          id="search_results.accounts"
          defaultMessage="People"
        />
      </h5>
      <SearchUsers listId={props.listId} />
    </div>
  );
};

export default UsersListCreator;
