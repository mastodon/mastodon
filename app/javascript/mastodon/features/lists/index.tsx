import { useEffect, useMemo, useCallback } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';
import { Link } from 'react-router-dom';

import AddIcon from '@/material-icons/400-24px/add.svg?react';
import ListAltIcon from '@/material-icons/400-24px/list_alt.svg?react';
import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';
import SquigglyArrow from '@/svg-icons/squiggly_arrow.svg?react';
import { fetchLists } from 'mastodon/actions/lists';
import { openModal } from 'mastodon/actions/modal';
import Column from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import { Icon } from 'mastodon/components/icon';
import ScrollableList from 'mastodon/components/scrollable_list';
import DropdownMenuContainer from 'mastodon/containers/dropdown_menu_container';
import { getOrderedLists } from 'mastodon/selectors/lists';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

const messages = defineMessages({
  heading: { id: 'column.lists', defaultMessage: 'Lists' },
  create: { id: 'lists.create_list', defaultMessage: 'Create list' },
  edit: { id: 'lists.edit', defaultMessage: 'Edit list' },
  delete: { id: 'lists.delete', defaultMessage: 'Delete list' },
  more: { id: 'status.more', defaultMessage: 'More' },
});

const ListItem: React.FC<{
  id: string;
  title: string;
}> = ({ id, title }) => {
  const dispatch = useAppDispatch();
  const intl = useIntl();

  const handleDeleteClick = useCallback(() => {
    dispatch(
      openModal({
        modalType: 'CONFIRM_DELETE_LIST',
        modalProps: {
          listId: id,
        },
      }),
    );
  }, [dispatch, id]);

  const menu = useMemo(
    () => [
      { text: intl.formatMessage(messages.edit), to: `/lists/${id}/edit` },
      { text: intl.formatMessage(messages.delete), action: handleDeleteClick },
    ],
    [intl, id, handleDeleteClick],
  );

  return (
    <div className='lists__item'>
      <Link to={`/lists/${id}`} className='lists__item__title'>
        <Icon id='list-ul' icon={ListAltIcon} />
        <span>{title}</span>
      </Link>

      <DropdownMenuContainer
        scrollKey='lists'
        items={menu}
        icons='ellipsis-h'
        iconComponent={MoreHorizIcon}
        direction='right'
        title={intl.formatMessage(messages.more)}
      />
    </div>
  );
};

const Lists: React.FC<{
  multiColumn?: boolean;
}> = ({ multiColumn }) => {
  const dispatch = useAppDispatch();
  const intl = useIntl();
  const lists = useAppSelector((state) => getOrderedLists(state));

  useEffect(() => {
    dispatch(fetchLists());
  }, [dispatch]);

  const emptyMessage = (
    <>
      <span>
        <FormattedMessage
          id='lists.no_lists_yet'
          defaultMessage='No lists yet.'
        />
        <br />
        <FormattedMessage
          id='lists.create_a_list_to_organize'
          defaultMessage='Create a new list to organize your Home feed'
        />
      </span>

      <SquigglyArrow className='empty-column-indicator__arrow' />
    </>
  );

  return (
    <Column
      bindToDocument={!multiColumn}
      label={intl.formatMessage(messages.heading)}
    >
      <ColumnHeader
        title={intl.formatMessage(messages.heading)}
        icon='list-ul'
        iconComponent={ListAltIcon}
        multiColumn={multiColumn}
        extraButton={
          <Link
            to='/lists/new'
            className='column-header__button'
            title={intl.formatMessage(messages.create)}
            aria-label={intl.formatMessage(messages.create)}
          >
            <Icon id='plus' icon={AddIcon} />
          </Link>
        }
      />

      <ScrollableList
        scrollKey='lists'
        emptyMessage={emptyMessage}
        bindToDocument={!multiColumn}
      >
        {lists.map((list) => (
          <ListItem key={list.id} id={list.id} title={list.title} />
        ))}
      </ScrollableList>

      <Helmet>
        <title>{intl.formatMessage(messages.heading)}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default Lists;
