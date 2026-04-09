import { useEffect } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';
import { Link } from 'react-router-dom';

import AddIcon from '@/material-icons/400-24px/add.svg?react';
import CollectionsFilledIcon from '@/material-icons/400-24px/category-fill.svg?react';
import SquigglyArrow from '@/svg-icons/squiggly_arrow.svg?react';
import { Column } from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import { DisplayNameSimple } from 'mastodon/components/display_name/simple';
import { Icon } from 'mastodon/components/icon';
import {
  ItemList,
  Scrollable,
} from 'mastodon/components/scrollable_list/components';
import { useAccount } from 'mastodon/hooks/useAccount';
import { useAccountId, useCurrentAccountId } from 'mastodon/hooks/useAccountId';
import {
  fetchAccountCollections,
  selectAccountCollections,
} from 'mastodon/reducers/slices/collections';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { CollectionListItem } from './components/collection_list_item';
import { messages as editorMessages } from './editor';

const messages = defineMessages({
  headingMe: { id: 'column.my_collections', defaultMessage: 'My collections' },
  headingOther: {
    id: 'column.other_collections',
    defaultMessage: 'Collections by {name}',
  },
});

export const Collections: React.FC<{
  multiColumn?: boolean;
}> = ({ multiColumn }) => {
  const dispatch = useAppDispatch();
  const intl = useIntl();
  const me = useCurrentAccountId();
  const accountId = useAccountId();
  const account = useAccount(accountId);

  const { collections, status } = useAppSelector((state) =>
    selectAccountCollections(state, accountId),
  );

  useEffect(() => {
    if (accountId) {
      void dispatch(fetchAccountCollections({ accountId }));
    }
  }, [dispatch, accountId]);

  const emptyMessage =
    status === 'error' || !accountId ? (
      <FormattedMessage
        id='collections.error_loading_collections'
        defaultMessage='There was an error when trying to load your collections.'
        tagName='span'
      />
    ) : (
      <>
        <span>
          <FormattedMessage
            id='collections.no_collections_yet'
            defaultMessage='No collections yet.'
          />
          <br />
          <FormattedMessage
            id='collections.create_a_collection_hint'
            defaultMessage='Create a collection to recommend or share your favourite accounts with others.'
          />
        </span>

        <SquigglyArrow className='empty-column-indicator__arrow' />
      </>
    );

  const isOwnCollection = accountId === me;
  const titleMessage = isOwnCollection
    ? messages.headingMe
    : messages.headingOther;

  const pageTitle = intl.formatMessage(titleMessage, {
    name: account?.get('display_name'),
  });
  const pageTitleHtml = intl.formatMessage(titleMessage, {
    name: <DisplayNameSimple account={account} />,
  });

  return (
    <Column bindToDocument={!multiColumn} label={pageTitle}>
      <ColumnHeader
        title={pageTitleHtml}
        icon='collections'
        iconComponent={CollectionsFilledIcon}
        multiColumn={multiColumn}
        extraButton={
          isOwnCollection && (
            <Link
              to='/collections/new'
              className='column-header__button'
              title={intl.formatMessage(editorMessages.create)}
              aria-label={intl.formatMessage(editorMessages.create)}
            >
              <Icon id='plus' icon={AddIcon} />
            </Link>
          )
        }
      />

      <Scrollable>
        <ItemList emptyMessage={emptyMessage} isLoading={status === 'loading'}>
          {collections.map((item, index) => (
            <CollectionListItem
              withTimestamp
              withAuthorHandle={false}
              key={item.id}
              collection={item}
              positionInList={index + 1}
              listSize={collections.length}
            />
          ))}
        </ItemList>
      </Scrollable>

      <Helmet>
        <title>{pageTitle}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};
