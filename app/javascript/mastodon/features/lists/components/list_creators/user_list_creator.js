import React from 'react';

import Account from '../../../list_editor/components/account';
import Search from '../../../list_editor/components/search';
import Motion from '../../../ui/util/optional_motion';
import spring from 'react-motion/lib/spring';

import clearListSuggestions from '../../../../actions/lists';

const UserListCreator = props => {

    const showSearch = props.searchAccountIds.size > 0;

    const onClear = () => {
        dispatch(clearListSuggestions());
      };

    return (
        <div>
          <Search />

          <div className="drawer__pager">
            <div className="drawer__inner list-editor__accounts">
              {props.accountIds.map((accountId) => (
                <Account key={accountId} accountId={accountId} added />
              ))}
            </div>

            {showSearch && (
              <div
                role="button"
                tabIndex="-1"
                className="drawer__backdrop"
                onClick={onClear}
              />
            )}

            <Motion
              defaultStyle={{ x: -100 }}
              style={{
                x: spring(showSearch ? 0 : -100, {
                  stiffness: 210,
                  damping: 20,
                }),
              }}
            >
              {({ x }) => (
                <div
                  className="drawer__inner backdrop"
                  style={{
                    transform: x === 0 ? null : `translateX(${x}%)`,
                    visibility: x === -100 ? "hidden" : "visible",
                  }}
                >
                  {props.searchAccountIds.map((accountId) => (
                    <Account key={accountId} accountId={accountId} />
                  ))}
                </div>
              )}
            </Motion>
          </div>
        </div>
    )
}

export default UserListCreator;
