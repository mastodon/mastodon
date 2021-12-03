import React, { useState, useEffect } from "react";
import { FormattedMessage, injectIntl, defineMessages } from "react-intl";
import { useSelector, useDispatch } from "react-redux";
import RadioButton from "../../../components/radio_button";

import IconButton from "../../../components/icon_button";
import {
  changeListEditorTitle,
  changeListEditorType,
  submitListEditor,
  resetListEditor,
} from "../../../actions/lists";

import UserListCreator from "./list_creators/user_list_creator";

const messages = defineMessages({
  listCreator: { id: "lists.new.creator", defaultMessage: "List creator" },
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
  const [listType, setListType] = useState("users");

  const dispatch = useDispatch();

  const [value, disabled, accountIds, searchAccountIds, listTypeValue] =
    useSelector((state) => [
      state.getIn(["listEditor", "title"]),
      state.getIn(["listEditor", "isSubmitting"]),
      state.getIn(["listEditor", "accounts", "items"]),
      state.getIn(["listEditor", "suggestions", "items"]),
      state.getIn(["listEditor", "listType"]),
    ]);

  useEffect(() => {
    return () => {
      dispatch(resetListEditor());
    };
  }, []);

  useEffect(() => {}, [listName]);

  const handleChange = ({ target }) => {
    dispatch(changeListEditorTitle(target.value));
  };

  const handleListTypeChange = ({ target }) => {
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

  let creator;

  if (listName && listTypeValue === "users") {
    creator = (
      <UserListCreator
        accountIds={accountIds}
        searchAccountIds={searchAccountIds}
      />
    );
  }
  else if (listName && listTypeValue === "hashtag") {

  }
  

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
      {creator}
    </div>
  );
};

export default injectIntl(CreateNewListForm);