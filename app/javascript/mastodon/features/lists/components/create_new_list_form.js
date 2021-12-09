import React, { useState, useEffect } from 'react';
import { injectIntl, defineMessages } from 'react-intl';
import { useSelector, useDispatch } from 'react-redux';

import IconButton from '../../../components/icon_button';
import {
  changeListEditorTitle,
  submitListEditor,
  resetListEditor,
  setupListEditor,
} from '../../../actions/lists';

import HashtagListCreator from './list_creators/hashtag_list_creator';
import UsersListCreator from './list_creators/Users_list_creator';

const messages = defineMessages({
  label: {
    id: 'lists.new.title_placeholder',
    defaultMessage: 'New list title',
  },
  title: { id: 'lists.new.create', defaultMessage: 'Add list' },
});

const CreateNewListForm = (props) => {
  const { intl } = props;

  const label = intl.formatMessage(messages.label);
  const title = intl.formatMessage(messages.title);

  const [listName, setListName] = useState(false);

  const dispatch = useDispatch();

  const [value, disabled, hashtagsUsers] = useSelector((state) => [
    state.getIn(['listEditor', 'title']),
    state.getIn(['listEditor', 'isSubmitting']),
    state.getIn(['listEditor', 'hashtagsUsers']),
  ]);

  useEffect(() => {
    if (props.listId !== undefined) {
      setListName(true);
      dispatch(setupListEditor(props.listId));
    }
    return () => {
      dispatch(resetListEditor());
    };
  }, []);

  useEffect(() => {}, [listName]);

  const handleChange = ({ target }) => {
    dispatch(changeListEditorTitle(target.value));
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

  return (
    <div className="list-creator">
      <form className="column-settings__row" onSubmit={handleSubmit}>
        <div className="column-inline-form">
          <label>
            <span style={{ display: 'none' }}>{label}</span>

            <input
              className="setting-text"
              value={value}
              disabled={disabled}
              onChange={handleChange}
              placeholder={value === '' ? label : value}
            />
          </label>

          <IconButton
            disabled={disabled || !value}
            icon={!listName ? 'plus' : 'check'}
            title={title}
            onClick={handleClick}
          />
        </div>
      </form>
      {listName && <HashtagListCreator listId={props.listId} hashtagsUsers={hashtagsUsers} />}
      {listName && <UsersListCreator listId={props.listId} />}
    </div>
  );
};

export default injectIntl(CreateNewListForm);
