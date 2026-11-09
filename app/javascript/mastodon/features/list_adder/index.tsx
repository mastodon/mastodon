import { useEffect, useState, useCallback, useId } from 'react';

import { FormattedMessage, useIntl, defineMessages } from 'react-intl';

import { isFulfilled } from '@reduxjs/toolkit';

import { RssSimpleIcon, XIcon } from '@phosphor-icons/react';

import { Toggle } from '@/mastodon/components/form_fields';
import { fetchLists } from 'mastodon/actions/lists';
import { createList } from 'mastodon/actions/lists_typed';
import {
  apiGetAccountLists,
  apiAddAccountToList,
  apiRemoveAccountFromList,
} from 'mastodon/api/lists';
import type { ApiListJSON } from 'mastodon/api_types/lists';
import { Button, IconButton } from 'mastodon/components/button';
import { Icon } from 'mastodon/components/icon';
import { NavigationFocusTarget } from 'mastodon/components/navigation_focus_target';
import { getOrderedLists } from 'mastodon/selectors/lists';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

const messages = defineMessages({
  newFeed: {
    id: 'custom_feeds.new_feed_name',
    defaultMessage: 'New feed name',
  },
  createList: {
    id: 'lists.create',
    defaultMessage: 'Create',
  },
  close: {
    id: 'lightbox.close',
    defaultMessage: 'Close',
  },
});

const ListItem: React.FC<{
  id: string;
  title: string;
  checked: boolean;
  onChange: (id: string, checked: boolean) => void;
}> = ({ id, title, checked, onChange }) => {
  const uniqueId = useId();

  const handleChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      onChange(id, e.target.checked);
    },
    [id, onChange],
  );

  return (
    <label className='lists__item' htmlFor={uniqueId}>
      <div className='lists__item__title'>
        <Icon id='list-ul' icon={RssSimpleIcon} />
        <span>{title}</span>
      </div>

      <Toggle id={uniqueId} checked={checked} onChange={handleChange} />
    </label>
  );
};

const NewListItem: React.FC<{
  onCreate: (list: ApiListJSON) => void;
}> = ({ onCreate }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const [title, setTitle] = useState('');

  const handleChange = useCallback(
    ({ target: { value } }: React.ChangeEvent<HTMLInputElement>) => {
      setTitle(value);
    },
    [setTitle],
  );

  const handleSubmit = useCallback(() => {
    if (title.trim().length === 0) {
      return;
    }

    void dispatch(createList({ title })).then((result) => {
      if (isFulfilled(result)) {
        onCreate(result.payload);
        setTitle('');
      }

      return '';
    });
  }, [setTitle, dispatch, onCreate, title]);

  return (
    <form className='lists__item' onSubmit={handleSubmit}>
      <label className='lists__item__title'>
        <Icon id='list-ul' icon={RssSimpleIcon} />

        <input
          type='text'
          value={title}
          onChange={handleChange}
          maxLength={30}
          required
          placeholder={intl.formatMessage(messages.newFeed)}
        />
      </label>

      <Button type='submit' variant='solid' color='accent' size='sm'>
        {intl.formatMessage(messages.createList)}
      </Button>
    </form>
  );
};

const ListAdder: React.FC<{
  accountId: string;
  onClose: () => void;
}> = ({ accountId, onClose }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const account = useAppSelector((state) => state.accounts.get(accountId));
  const lists = useAppSelector((state) => getOrderedLists(state));
  const [listIds, setListIds] = useState<string[]>([]);

  useEffect(() => {
    void dispatch(fetchLists());

    apiGetAccountLists(accountId)
      .then((data) => {
        setListIds(data.map((l) => l.id));
        return '';
      })
      .catch(() => {
        // Nothing
      });
  }, [dispatch, setListIds, accountId]);

  const handleToggle = useCallback(
    (listId: string, checked: boolean) => {
      if (checked) {
        setListIds((currentListIds) => [listId, ...currentListIds]);

        apiAddAccountToList(listId, accountId).catch(() => {
          setListIds((currentListIds) =>
            currentListIds.filter((id) => id !== listId),
          );
        });
      } else {
        setListIds((currentListIds) =>
          currentListIds.filter((id) => id !== listId),
        );

        apiRemoveAccountFromList(listId, accountId).catch(() => {
          setListIds((currentListIds) => [listId, ...currentListIds]);
        });
      }
    },
    [setListIds, accountId],
  );

  const handleCreate = useCallback(
    (list: ApiListJSON) => {
      setListIds((currentListIds) => [list.id, ...currentListIds]);

      apiAddAccountToList(list.id, accountId).catch(() => {
        setListIds((currentListIds) =>
          currentListIds.filter((id) => id !== list.id),
        );
      });
    },
    [setListIds, accountId],
  );

  return (
    <div className='modal-root__modal dialog-modal'>
      <div className='dialog-modal__header'>
        <IconButton
          className='dialog-modal__header__close'
          icon={XIcon}
          onClick={onClose}
          size='sm'
          variant='ghost'
        >
          {intl.formatMessage(messages.close)}
        </IconButton>

        <NavigationFocusTarget as='h1' className='dialog-modal__header__title'>
          <FormattedMessage
            id='custom_feeds.add_to_feeds'
            defaultMessage='Add {name} to custom feeds'
            values={{ name: <strong>@{account?.acct}</strong> }}
          />
        </NavigationFocusTarget>
      </div>

      <div className='dialog-modal__content'>
        <div className='lists-scrollable'>
          <NewListItem onCreate={handleCreate} />

          {lists.map((list) => (
            <ListItem
              key={list.id}
              id={list.id}
              title={list.title}
              checked={listIds.includes(list.id)}
              onChange={handleToggle}
            />
          ))}
        </div>
      </div>
    </div>
  );
};

// eslint-disable-next-line import/no-default-export
export default ListAdder;
