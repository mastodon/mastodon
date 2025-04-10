import { useEffect, useState, useCallback, useRef } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';

import { isFulfilled } from '@reduxjs/toolkit';

import TagIcon from '@/material-icons/400-24px/tag.svg?react';
import { unfollowHashtag } from 'mastodon/actions/tags_typed';
import { apiGetFollowedTags } from 'mastodon/api/tags';
import type { ApiHashtagJSON } from 'mastodon/api_types/tags';
import { Button } from 'mastodon/components/button';
import { Column } from 'mastodon/components/column';
import type { ColumnRef } from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import { Hashtag } from 'mastodon/components/hashtag';
import ScrollableList from 'mastodon/components/scrollable_list';
import { useAppDispatch } from 'mastodon/store';

const messages = defineMessages({
  heading: { id: 'followed_tags', defaultMessage: 'Followed hashtags' },
});

const FollowedTag: React.FC<{
  tag: ApiHashtagJSON;
  onUnfollow: (arg0: string) => void;
}> = ({ tag, onUnfollow }) => {
  const dispatch = useAppDispatch();
  const tagId = tag.name;

  const handleClick = useCallback(() => {
    void dispatch(unfollowHashtag({ tagId })).then((result) => {
      if (isFulfilled(result)) {
        onUnfollow(tagId);
      }

      return '';
    });
  }, [dispatch, onUnfollow, tagId]);

  const people =
    parseInt(tag.history[0].accounts) +
    parseInt(tag.history[1]?.accounts ?? '');

  return (
    <Hashtag
      name={tag.name}
      to={`/tags/${tag.name}`}
      withGraph={false}
      people={people}
    >
      <Button onClick={handleClick}>
        <FormattedMessage id='account.unfollow' defaultMessage='Unfollow' />
      </Button>
    </Hashtag>
  );
};

const FollowedTags: React.FC<{ multiColumn: boolean }> = ({ multiColumn }) => {
  const intl = useIntl();
  const [tags, setTags] = useState<ApiHashtagJSON[]>([]);
  const [loading, setLoading] = useState(false);
  const [next, setNext] = useState<string | undefined>();
  const hasMore = !!next;
  const columnRef = useRef<ColumnRef>(null);

  useEffect(() => {
    setLoading(true);

    void apiGetFollowedTags()
      .then(({ tags, links }) => {
        const next = links.refs.find((link) => link.rel === 'next');

        setTags(tags);
        setLoading(false);
        setNext(next?.uri);

        return '';
      })
      .catch(() => {
        setLoading(false);
      });
  }, [setTags, setLoading, setNext]);

  const handleLoadMore = useCallback(() => {
    setLoading(true);

    void apiGetFollowedTags(next)
      .then(({ tags, links }) => {
        const next = links.refs.find((link) => link.rel === 'next');

        setLoading(false);
        setTags((previousTags) => [...previousTags, ...tags]);
        setNext(next?.uri);

        return '';
      })
      .catch(() => {
        setLoading(false);
      });
  }, [setTags, setLoading, setNext, next]);

  const handleUnfollow = useCallback(
    (tagId: string) => {
      setTags((tags) => tags.filter((tag) => tag.name !== tagId));
    },
    [setTags],
  );

  const handleHeaderClick = useCallback(() => {
    columnRef.current?.scrollTop();
  }, []);

  const emptyMessage = (
    <FormattedMessage
      id='empty_column.followed_tags'
      defaultMessage='You have not followed any hashtags yet. When you do, they will show up here.'
    />
  );

  return (
    <Column
      bindToDocument={!multiColumn}
      ref={columnRef}
      label={intl.formatMessage(messages.heading)}
    >
      <ColumnHeader
        icon='hashtag'
        iconComponent={TagIcon}
        title={intl.formatMessage(messages.heading)}
        onClick={handleHeaderClick}
        multiColumn={multiColumn}
        showBackButton
      />

      <ScrollableList
        scrollKey='followed_tags'
        emptyMessage={emptyMessage}
        hasMore={hasMore}
        isLoading={loading}
        showLoading={loading && tags.length === 0}
        onLoadMore={handleLoadMore}
        trackScroll={!multiColumn}
        bindToDocument={!multiColumn}
      >
        {tags.map((tag) => (
          <FollowedTag key={tag.name} tag={tag} onUnfollow={handleUnfollow} />
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
export default FollowedTags;
