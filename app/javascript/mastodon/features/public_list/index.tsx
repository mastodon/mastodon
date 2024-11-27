import { useEffect, useCallback } from 'react';

import { FormattedMessage, useIntl, defineMessages } from 'react-intl';

import { Helmet } from 'react-helmet';
import { NavLink, useParams, Route, Switch } from 'react-router-dom';

import PackageIcon from '@/material-icons/400-24px/package_2.svg?react';
import ShareIcon from '@/material-icons/400-24px/share.svg?react';
import { fetchList } from 'mastodon/actions/lists';
import { Column } from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import { CopyIconButton } from 'mastodon/components/copy_icon_button';
import { Icon } from 'mastodon/components/icon';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import BundleColumnError from 'mastodon/features/ui/components/bundle_column_error';
import type { List } from 'mastodon/models/list';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import { Hero } from './components/hero';
import { Members } from './members';
import { Statuses } from './statuses';

interface PublicListParams {
  id: string;
  slug?: string;
}

const messages = defineMessages({
  copyLink: { id: '', defaultMessage: 'Copy link' },
  shareLink: { id: '', defaultMessage: 'Share link' },
});

const CopyLinkButton: React.FC<{
  list: List;
}> = ({ list }) => {
  const intl = useIntl();

  const handleClick = useCallback(() => {
    void navigator.share({
      url: list.url,
    });
  }, [list]);

  if ('share' in navigator) {
    return (
      <button
        className='column-header__button'
        onClick={handleClick}
        title={intl.formatMessage(messages.shareLink)}
        aria-label={intl.formatMessage(messages.shareLink)}
      >
        <Icon id='' icon={ShareIcon} />
      </button>
    );
  }

  return (
    <CopyIconButton
      className='column-header__button'
      title={intl.formatMessage(messages.copyLink)}
      value={list.url}
    />
  );
};

const PublicList: React.FC<{
  multiColumn: boolean;
}> = ({ multiColumn }) => {
  const { id } = useParams<PublicListParams>();
  const dispatch = useAppDispatch();
  const list = useAppSelector((state) => state.lists.get(id));
  const accountId = list?.account_id;
  const slug = list?.slug ? `${list.id}-${list.slug}` : list?.id;

  useEffect(() => {
    dispatch(fetchList(id));
  }, [dispatch, id]);

  if (typeof list === 'undefined') {
    return (
      <Column>
        <LoadingIndicator />
      </Column>
    );
  } else if (list === null || !accountId) {
    return <BundleColumnError multiColumn={multiColumn} errorType='routing' />;
  }

  return (
    <Column>
      <ColumnHeader
        icon='package'
        iconComponent={PackageIcon}
        title={list.title}
        multiColumn={multiColumn}
        extraButton={<CopyLinkButton list={list} />}
      />

      <Hero list={list} />

      <div className='account__section-headline'>
        <NavLink exact to={`/starter-pack/${slug}`}>
          <FormattedMessage tagName='div' id='' defaultMessage='Members' />
        </NavLink>

        <NavLink exact to={`/starter-pack/${slug}/posts`}>
          <FormattedMessage tagName='div' id='' defaultMessage='Posts' />
        </NavLink>
      </div>

      <Switch>
        <Route
          path={['/starter-pack/:id(\\d+)', '/starter-pack/:id(\\d+)-:slug']}
          exact
          component={Members}
        />
        <Route
          path={[
            '/starter-pack/:id(\\d+)/posts',
            '/starter-pack/:id(\\d+)-:slug/posts',
          ]}
          component={Statuses}
        />
      </Switch>

      <Helmet>
        <title>{list.title}</title>
        <meta name='robots' content='all' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default PublicList;
