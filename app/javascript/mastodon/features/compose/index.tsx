import { useEffect } from 'react';

import { useIntl } from 'react-intl';

import { Helmet } from '@unhead/react/helmet';

import { Column } from '@/mastodon/components/column';
import { ColumnHeader } from '@/mastodon/components/column_header';
import { mountCompose, unmountCompose } from 'mastodon/actions/compose';
import { useAppDispatch } from 'mastodon/store';

import { ComposeForm } from './form';

const Compose: React.FC<{ multiColumn: boolean }> = ({ multiColumn }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();

  useEffect(() => {
    dispatch(mountCompose());

    return () => {
      dispatch(unmountCompose());
    };
  }, [dispatch]);

  const title = intl.formatMessage({
    id: 'tabs_bar.publish',
    defaultMessage: 'New Post',
  });

  return (
    <Column bindToDocument={!multiColumn} label={title}>
      <ColumnHeader withBackButton title={title} />

      <div className='scrollable scrollable--flex'>
        <ComposeForm autoFocus headless />
      </div>

      <Helmet>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default Compose;
