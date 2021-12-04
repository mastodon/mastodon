import React, { useState, useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { injectIntl, FormattedMessage, defineMessages } from 'react-intl';
import IconButton from '../../../../components/icon_button';

import {
  changeListEditorHashtag,
  submitListEditor,
} from '../../../../actions/lists';

const messages = defineMessages({
  hashtags: { id: 'lists.extend_list.hashtags', defaultMessage: 'Hashtags' },
  placeholder: {
    id: 'lists.extend_list.hashtags_placeholder',
    defaultMessage: '#first_hashtag #second_hashtag',
  },
  title: { id: 'lists.extend_list.create', defaultMessage: 'Add hashtags' },
});

const HashtagListCreator = (props) => {
  const { intl } = props;

  const label = intl.formatMessage(messages.placeholder);
  const title = intl.formatMessage(messages.title);

  const [hashtag, setHashtag] = useState(false);

  const dispatch = useDispatch();

  useEffect(() => {}, [hashtag]);

  const [hashtagValue, disabled] = useSelector((state) => [
    state.getIn(['listEditor', 'hashtags']),
    state.getIn(['listEditor', 'isSubmitting']),
  ]);

  const handleChange = ({ target }) => {
    dispatch(changeListEditorHashtag(target.value));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    setHashtag(true);
    dispatch(submitListEditor(false));
  };

  const handleClick = () => {
    setHashtag(true);
    dispatch(submitListEditor(false));
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
            <textarea
              className="setting-text"
              value={hashtagValue}
              disabled={disabled}
              onChange={handleChange}
              placeholder={!hashtag ? label : hashtagValue}
            />
          </label>
          <IconButton
            disabled={disabled || !hashtagValue}
            icon={!hashtag ? 'plus' : 'check'}
            title={title}
            onClick={handleClick}
          />
        </div>
      </form>
    </div>
  );
};

export default injectIntl(HashtagListCreator);
