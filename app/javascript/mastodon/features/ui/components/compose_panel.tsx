import { useCallback, useEffect } from 'react';

import { useLayout } from '@/mastodon/hooks/useLayout';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import {
  changeComposing,
  mountCompose,
  unmountCompose,
} from 'mastodon/actions/compose';
import ServerBanner from 'mastodon/components/server_banner';
import { Search } from 'mastodon/features/compose/components/search';
import ComposeFormContainer from 'mastodon/features/compose/containers/compose_form_container';
import { LinkFooter } from 'mastodon/features/ui/components/link_footer';
import { useIdentity } from 'mastodon/identity_context';

export const ComposePanel: React.FC = () => {
  const dispatch = useAppDispatch();
  const handleFocus = useCallback(() => {
    dispatch(changeComposing(true));
  }, [dispatch]);
  const { signedIn } = useIdentity();
  const hideComposer = useAppSelector((state) => {
    const mounted = state.compose.get('mounted');
    if (typeof mounted === 'number') {
      return mounted > 1;
    }
    return false;
  });

  useEffect(() => {
    dispatch(mountCompose());
    return () => {
      dispatch(unmountCompose());
    };
  }, [dispatch]);

  const { singleColumn } = useLayout();

  return (
    <div className='compose-panel' onFocus={handleFocus}>
      <Search singleColumn={singleColumn} />

      {!signedIn && (
        <>
          <ServerBanner />
          <div className='flex-spacer' />
        </>
      )}

      {signedIn && !hideComposer && <ComposeFormContainer singleColumn />}
      {signedIn && hideComposer && <div className='compose-form' />}

      <LinkFooter multiColumn={!singleColumn} />
    </div>
  );
};
