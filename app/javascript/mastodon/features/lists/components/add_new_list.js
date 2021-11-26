import React from 'react';
import { injectIntl, defineMessages } from 'react-intl';
import { useDispatch } from 'react-redux';
import { openModal } from '../../../actions/modal';
import IconButton from '../../../components/icon_button';

const messages = defineMessages({
  title: { id: "lists.new.create", defaultMessage: "Create a new list" },
});

const AddNewList = (props) => {
  const dispatch = useDispatch();

  const { intl } = props;

  const title = intl.formatMessage(messages.title);

  const handleClick = () => {
    dispatch(openModal("NEW_LIST_ADDER"));
  };

  return (
    <div className="button-adder">
      {title}
      <IconButton icon="plus" title={title} onClick={handleClick} />
    </div>
  );
};

export default injectIntl(AddNewList);
