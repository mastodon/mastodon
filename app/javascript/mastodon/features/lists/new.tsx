import { useCallback, useState, useEffect } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import { useParams, useHistory, Link } from 'react-router-dom';

import { isFulfilled } from '@reduxjs/toolkit';

import { Helmet } from '@unhead/react/helmet';

import { Column } from '@/mastodon/components/column';
import { ColumnHeader as LegacyColumnHeader } from '@/mastodon/components/column/header';
import { ColumnHeader } from '@/mastodon/components/column_header';
import { NotSignedInIndicator } from '@/mastodon/components/not_signed_in_indicator';
import { useIdentity } from '@/mastodon/identity_context';
import { isRedesignEnabled } from '@/mastodon/utils/environment';
import ChevronRightIcon from '@/material-icons/400-24px/chevron_right.svg?react';
import ListAltIcon from '@/material-icons/400-24px/list_alt.svg?react';
import { fetchList } from 'mastodon/actions/lists';
import { createList, updateList } from 'mastodon/actions/lists_typed';
import { apiGetListAccounts } from 'mastodon/api/lists';
import type { ApiAccountJSON } from 'mastodon/api_types/accounts';
import type { RepliesPolicyType } from 'mastodon/api_types/lists';
import { Avatar } from 'mastodon/components/avatar';
import { AvatarGroup } from 'mastodon/components/avatar_group';
import {
  SelectField,
  TextInputField,
  Toggle,
} from 'mastodon/components/form_fields';
import { Icon } from 'mastodon/components/icon';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import type { List } from 'mastodon/models/list';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

const messagesLegacy = defineMessages({
  edit: { id: 'column.edit_list', defaultMessage: 'Edit list' },
  create: { id: 'column.create_list', defaultMessage: 'Create list' },
  manageMembers: {
    id: 'column.list_members',
    defaultMessage: 'Manage list members',
  },
  nameFieldLabel: { id: 'lists.list_name', defaultMessage: 'List name' },
  showRepliesTo: {
    id: 'lists.show_replies_to',
    defaultMessage: 'Include replies from list members to',
  },
  replyPolicyList: {
    id: 'lists.replies_policy.list',
    defaultMessage: 'Members of the list',
  },
  exclusiveHint: {
    id: 'lists.exclusive_hint',
    defaultMessage:
      'If someone is on this list, hide them in your Home feed to avoid seeing their posts twice.',
  },
});

const messagesRedesign = defineMessages({
  edit: { id: 'column.edit_custom_feed', defaultMessage: 'Edit Custom Feed' },
  create: {
    id: 'column.create_custom_feed',
    defaultMessage: 'Create Custom Feed',
  },
  manageMembers: {
    id: 'custom_feeds.manage_accounts',
    defaultMessage: 'Manage feed members',
  },
  nameFieldLabel: { id: 'custom_feeds.feed_name', defaultMessage: 'Feed name' },
  showRepliesTo: {
    id: 'custom_feeds.show_replies_to',
    defaultMessage: 'Include replies from feed members to',
  },
  replyPolicyList: {
    id: 'custom_feeds.replies_policy.members',
    defaultMessage: 'Members of the feed',
  },
  exclusiveHint: {
    id: 'custom_feeds.exclusive_hint',
    defaultMessage:
      'If someone is in this custom feed, hide them in your Home feed to avoid seeing their posts twice.',
  },
});

const messages = isRedesignEnabled() ? messagesRedesign : messagesLegacy;

const MembersLink: React.FC<{
  id: string;
}> = ({ id }) => {
  const intl = useIntl();
  const [avatarCount, setAvatarCount] = useState(0);
  const [avatarAccounts, setAvatarAccounts] = useState<ApiAccountJSON[]>([]);

  useEffect(() => {
    void apiGetListAccounts(id)
      .then((data) => {
        setAvatarCount(data.length);
        setAvatarAccounts(data.slice(0, 3));
      })
      .catch(() => {
        // Nothing
      });
  }, [id]);

  return (
    <Link to={`/lists/${id}/members`} className='app-form__link'>
      <div className='app-form__link__text'>
        <strong>
          {intl.formatMessage(messages.manageMembers)}
          <Icon id='chevron_right' icon={ChevronRightIcon} />
        </strong>
        <FormattedMessage
          id='lists.list_members_count'
          defaultMessage='{count, plural, one {# member} other {# members}}'
          values={{ count: avatarCount }}
        />
      </div>

      <AvatarGroup compact>
        {avatarAccounts.map((a) => (
          <Avatar key={a.id} account={a} size={30} />
        ))}
      </AvatarGroup>
    </Link>
  );
};

const NewList: React.FC<{ list?: List | null }> = ({ list }) => {
  const dispatch = useAppDispatch();
  const history = useHistory();
  const intl = useIntl();

  const {
    id,
    title: initialTitle = '',
    exclusive: initialExclusive = false,
    replies_policy: initialRepliesPolicy = 'list',
  } = list ?? {};

  const [title, setTitle] = useState(initialTitle);
  const [exclusive, setExclusive] = useState(initialExclusive);
  const [repliesPolicy, setRepliesPolicy] =
    useState<RepliesPolicyType>(initialRepliesPolicy);
  const [submitting, setSubmitting] = useState(false);

  const handleTitleChange = useCallback(
    ({ target: { value } }: React.ChangeEvent<HTMLInputElement>) => {
      setTitle(value);
    },
    [setTitle],
  );

  const handleExclusiveChange = useCallback(
    ({ target: { checked } }: React.ChangeEvent<HTMLInputElement>) => {
      setExclusive(checked);
    },
    [setExclusive],
  );

  const handleRepliesPolicyChange = useCallback(
    ({ target: { value } }: React.ChangeEvent<HTMLSelectElement>) => {
      setRepliesPolicy(value as RepliesPolicyType);
    },
    [setRepliesPolicy],
  );

  const handleSubmit = useCallback(() => {
    setSubmitting(true);

    if (id) {
      void dispatch(
        updateList({
          id,
          title,
          exclusive,
          replies_policy: repliesPolicy,
        }),
      ).then(() => {
        setSubmitting(false);
        return '';
      });
    } else {
      void dispatch(
        createList({
          title,
          exclusive,
          replies_policy: repliesPolicy,
        }),
      ).then((result) => {
        setSubmitting(false);

        if (isFulfilled(result)) {
          history.replace(`/lists/${result.payload.id}/edit`);
          history.push(`/lists/${result.payload.id}/members`);
        }

        return '';
      });
    }
  }, [history, dispatch, setSubmitting, id, title, exclusive, repliesPolicy]);

  return (
    <form className='simple_form app-form' onSubmit={handleSubmit}>
      <div className='fields-group'>
        <TextInputField
          required
          maxLength={30}
          label={intl.formatMessage(messages.nameFieldLabel)}
          value={title}
          onChange={handleTitleChange}
          id='list_title'
        />
      </div>

      <div className='fields-group'>
        <SelectField
          label={intl.formatMessage(messages.showRepliesTo)}
          value={repliesPolicy}
          onChange={handleRepliesPolicyChange}
          id='list_replies_policy'
        >
          <option value='none'>
            <FormattedMessage
              id='lists.replies_policy.none'
              defaultMessage='No one'
            />
          </option>
          <option value='list'>
            {intl.formatMessage(messages.replyPolicyList)}
          </option>
          <option value='followed'>
            <FormattedMessage
              id='lists.replies_policy.followed'
              defaultMessage='Any followed user'
            />
          </option>
        </SelectField>
      </div>

      {id && (
        <div className='fields-group'>
          <MembersLink id={id} />
        </div>
      )}

      <div className='fields-group'>
        {/* eslint-disable-next-line jsx-a11y/label-has-associated-control */}
        <label className='app-form__toggle'>
          <div className='app-form__toggle__label'>
            <strong>
              <FormattedMessage
                id='lists.exclusive'
                defaultMessage='Hide members in Home'
              />
            </strong>
            <span className='hint'>
              {intl.formatMessage(messages.exclusiveHint)}
            </span>
          </div>

          <div className='app-form__toggle__toggle'>
            <div>
              <Toggle checked={exclusive} onChange={handleExclusiveChange} />
            </div>
          </div>
        </label>
      </div>

      <div className='actions'>
        <button className='button' type='submit'>
          {submitting ? (
            <LoadingIndicator />
          ) : id ? (
            <FormattedMessage id='lists.save' defaultMessage='Save' />
          ) : (
            <FormattedMessage id='lists.create' defaultMessage='Create' />
          )}
        </button>
      </div>
    </form>
  );
};

const NewListWrapper: React.FC<{
  multiColumn?: boolean;
}> = ({ multiColumn }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const { signedIn } = useIdentity();
  const { id } = useParams<{ id?: string }>();
  const list = useAppSelector((state) =>
    id ? state.lists.get(id) : undefined,
  );

  useEffect(() => {
    if (signedIn && id) {
      dispatch(fetchList(id));
    }
  }, [dispatch, signedIn, id]);

  const isLoading = id && !list;
  const title = intl.formatMessage(id ? messages.edit : messages.create);

  return (
    <Column bindToDocument={!multiColumn} label={title}>
      {isRedesignEnabled() ? (
        <ColumnHeader withBackButton title={title} />
      ) : (
        <LegacyColumnHeader
          title={title}
          icon='list-ul'
          iconComponent={ListAltIcon}
          multiColumn={multiColumn}
          showBackButton
        />
      )}

      <div className='scrollable'>
        {!signedIn ? (
          <NotSignedInIndicator />
        ) : isLoading ? (
          <LoadingIndicator />
        ) : (
          <NewList list={list} />
        )}
      </div>

      <Helmet>
        <title>{title}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default NewListWrapper;
