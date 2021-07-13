import { ScrollContainer as OriginalScrollContainer } from 'react-router-scroll-4';

// ScrollContainer is used to automatically scroll to the top when pushing a
// new history state and remembering the scroll position when going back.
// There are a few things we need to do differently, though.
const defaultShouldUpdateScroll = (prevRouterProps, { location }) => {
  // If the change is caused by opening a modal, do not scroll to top
  return !(location.state?.mastodonModalKey && location.state?.mastodonModalKey !== prevRouterProps?.location?.state?.mastodonModalKey);
};

export default
class ScrollContainer extends OriginalScrollContainer {

  static defaultProps = {
    shouldUpdateScroll: defaultShouldUpdateScroll,
  };

}
