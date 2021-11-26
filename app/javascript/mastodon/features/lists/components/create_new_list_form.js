import React, { useState, useEffect } from 'react';
import { injectIntl, defineMessages } from 'react-intl';
import { useSelector, useDispatch } from 'react-redux';

import IconButton from '../../../components/icon_button';
import {
  changeListEditorTitle,
  submitListEditor,
  clearListSuggestions,
  resetListEditor,
} from '../../../actions/lists';
import Account from '../../list_editor/components/account';
import Search from '../../list_editor/components/search';
import Motion from '../../ui/util/optional_motion';
import spring from 'react-motion/lib/spring';

const messages = defineMessages({
  label: {
    id: "lists.new.title_placeholder",
    defaultMessage: "New list title",
  },
  title: { id: "lists.new.create", defaultMessage: "Add list" },
});

const CreateNewListForm = (props) => {
  const { intl } = props;

  const label = intl.formatMessage(messages.label);
  const title = intl.formatMessage(messages.title);

  const [listName, setListName] = useState(false);

  const dispatch = useDispatch();

  const [value, disabled, accountIds, searchAccountIds] = useSelector(
    (state) => [
      state.getIn(["listEditor", "title"]),
      state.getIn(["listEditor", "isSubmitting"]),
      state.getIn(["listEditor", "accounts", "items"]),
      state.getIn(["listEditor", "suggestions", "items"]),
    ]
  );

  const showSearch = searchAccountIds.size > 0;

  useEffect(() => {
    return () => {
      dispatch(resetListEditor());
    };
  }, []);

  useEffect(() => {
    console.log(listName);
  }, [listName]);

  const handleChange = (e) => {
    dispatch(changeListEditorTitle(e.target.value));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!listName) {
      setListName(true);
      dispatch(submitListEditor(true));
    } else {
      dispatch(submitListEditor(false));
    }
  };

  const handleClick = () => {
    if (!listName) {
      setListName(true);
      dispatch(submitListEditor(true));
    } else {
      dispatch(submitListEditor(false));
    }
  };

  const onClear = () => {
    dispatch(clearListSuggestions());
  };

  return (
    <div>
      <h4>List creator</h4>
      <form className="column-inline-form" onSubmit={handleSubmit}>
        <label>
          <span style={{ display: "none" }}>{label}</span>

          <input
            className="setting-text"
            value={value}
            disabled={disabled}
            onChange={handleChange}
            placeholder={value === "" ? label : value}
          />
        </label>

        <IconButton
          disabled={disabled || !value}
          icon={!listName ? "plus" : "check"}
          title={title}
          onClick={handleClick}
        />
      </form>

      {listName && (
        <div>
          <Search />

          <div className="drawer__pager">
            <div className="drawer__inner list-editor__accounts">
              {accountIds.map((accountId) => (
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
                  {searchAccountIds.map((accountId) => (
                    <Account key={accountId} accountId={accountId} />
                  ))}
                </div>
              )}
            </Motion>
          </div>
        </div>
      )}
    </div>
  );
};

export default injectIntl(CreateNewListForm);
