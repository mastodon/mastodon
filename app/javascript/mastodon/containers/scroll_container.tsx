import type { RouteComponentProps, StaticContext } from 'react-router';

import { ScrollContainer as OriginalScrollContainer } from 'react-router-scroll-4';
import type { ScrollContainerProps } from 'react-router-scroll-4';

export interface WithMastodonLocation {
  state?: MastodonLocationState;
}

export interface MastodonLocationState {
  mastodonModalKey?: string;
}

type MastodonRouteComponentProps = RouteComponentProps<
  object,
  StaticContext,
  MastodonLocationState
>;

// ScrollContainer is used to automatically scroll to the top when pushing a
// new history state and remembering the scroll position when going back.
// There are a few things we need to do differently, though.
const defaultShouldUpdateScroll = (
  prevRouterProps: ScrollContainerProps<WithMastodonLocation>,
  { location }: MastodonRouteComponentProps,
) => {
  // If the change is caused by opening a modal, do not scroll to top
  /* eslint-disable @typescript-eslint/no-unnecessary-condition */
  return !(
    location.state?.mastodonModalKey &&
    location.state.mastodonModalKey !==
      prevRouterProps.location?.state?.mastodonModalKey
  );
  /* eslint-enable @typescript-eslint/no-unnecessary-condition */
};

export class ScrollContainer extends OriginalScrollContainer {
  static defaultProps = {
    shouldUpdateScroll: defaultShouldUpdateScroll,
  };
}
