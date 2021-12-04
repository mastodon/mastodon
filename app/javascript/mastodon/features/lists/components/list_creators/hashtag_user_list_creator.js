import React, { useState, useEffect } from "react";
import { useSelector, useDispatch } from "react-redux";
import { injectIntl, FormattedMessage, defineMessages } from "react-intl";
import IconButton from "../../../../components/icon_button";

import {
  changeListEditorHashtag,
  submitListEditor,
  resetListEditor,
} from "../../../../actions/lists";

const messages = defineMessages({
  hashtags: { id: "lists.extend_list.hashtags", defaultMessage: "Hashtags" },
  placeholder: {
    id: "lists.extend_list.hashtags_placeholder",
    defaultMessage: "#yourhashtag",
  },
  title: { id: "lists.extend_list.create", defaultMessage: "Add hashtags" },
});

const HashtagUserListCreator = (props) => {
  const { intl } = props;

  const label = intl.formatMessage(messages.placeholder);
  const title = intl.formatMessage(messages.title);

  const [hashtag, setHashtag] = useState(false);

  const dispatch = useDispatch();

  const [hashtagValue, disabled] = useSelector((state) => [
    state.getIn(["listEditor", "hashtag"]),
    state.getIn(["listEditor", "isSubmitting"]),
  ]);

  useEffect(() => {
    return () => {
      dispatch(resetListEditor());
    };
  }, []);

  useEffect(() => {}, [hashtag]);

  const handleChange = ({ target }) => {
    dispatch(changeListEditorHashtag(target.value));
    console.log(target.value);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!hashtag) {
      console.log(hashtagValue);
      setHashtag(true);
      dispatch(submitListEditor(true));
    } else {
      dispatch(submitListEditor(false));
    }
  };

  const handleClick = () => {
    if (!hashtag) {
      console.log(hashtagValue);
      setHashtag(true);
      dispatch(submitListEditor(true));
    } else {
      dispatch(submitListEditor(false));
    }
  };

  return (
    <div className="extend-list">
      <form className="column-settings__row" onSubmit={handleSubmit}>
        <span className="column-settings__section">
          <FormattedMessage
            id="lists.extended_lists.hashtags"
            defaultMessage="Hashtags"
          />
        </span>
        <div className="column-inline-form">
          <label>
            <input
              className="setting-text"
              value={hashtagValue}
              disabled={disabled}
              onChange={handleChange}
              placeholder={hashtagValue === "" ? label : hashtagValue}
            />
          </label>
          <IconButton
            disabled={disabled || !hashtagValue}
            icon={"plus"}
            title={title}
            onClick={handleClick}
          />
        </div>
      </form>
    </div>
  );
};

export default injectIntl(HashtagUserListCreator);
