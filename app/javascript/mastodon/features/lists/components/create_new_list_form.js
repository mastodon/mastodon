import React, { useState, useEffect } from 'react';
import { FormattedMessage, injectIntl, defineMessages } from 'react-intl';
import { useSelector, useDispatch } from 'react-redux';

import IconButton from '../../../components/icon_button';
import RadioButton from '../../../components/radio_button';
import {
  changeListEditorTitle,
  changeListEditorType,
  submitListEditor,
  clearListSuggestions,
  resetListEditor,
} from '../../../actions/lists';
import Account from '../../list_editor/components/account';
import Search from '../../list_editor/components/search';
import Motion from '../../ui/util/optional_motion';
import spring from 'react-motion/lib/spring';

const messages = defineMessages({
  listCreator: {id: "lists.new.creator", defaultMessage: "List creator"},
  label: {
    id: "lists.new.title_placeholder",
    defaultMessage: "New list title",
  },
  title: { id: "lists.new.create", defaultMessage: "Add list" },
  hashtag: { id: "lists.extended_lists.hashtag", defaultMessage: "Hashtag" },
  users: { id: "lists.extended_lists.users", defaultMessage: "Users" },
  listTypes: {
    id: "lists.extended_lists.list_types",
    defaultMessage: "Choose list type:",
  },
});

const CreateNewListForm = (props) => {
  const { intl } = props;

  const label = intl.formatMessage(messages.label);
  const title = intl.formatMessage(messages.title);
  const listCreator = intl.formatMessage(messages.listCreator);

  const [listName, setListName] = useState(false);
  const [listType, setListType] = useState('users');

  const dispatch = useDispatch();

  const [value, disabled, accountIds, searchAccountIds, listTypeValue] = useSelector(
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
  }, [listName]);

  const handleChange = ({target}) => {
    dispatch(changeListEditorTitle(target.value));
  };

  const handleListTypeChange = ({target}) => {
    setListType(target.value);
    dispatch(changeListEditorType(target.value));
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
      <h4>{listCreator}</h4>
      <form className="column-settings__row" onSubmit={handleSubmit}>
        <div className="column-inline-form">
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
        </div>
        {!listName && (
          <div className="radio-button-list" role="group">
            <span className="column-settings__section">
              <FormattedMessage
                id="lists.extended_lists.list_types"
                defaultMessage="Choose list type:"
              />
            </span>
            <div className="column-settings__row">
              {["users", "hashtag"].map((type) => (
                <RadioButton
                  name="order"
                  key={type}
                  value={type}
                  label={intl.formatMessage(messages[type])}
                  checked={listType === type}
                  onChange={handleListTypeChange}
                />
              ))}
            </div>
          </div>
        )}
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
