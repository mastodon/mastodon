declare module 'react-router-scroll-4' {
  interface ScrollContainerProps<Location = unknown> {
    children: React.ReactElement;
    location?: Location;
    scrollKey: string;
    shouldUpdateScroll?: (
      // eslint-disable-next-line @typescript-eslint/consistent-type-imports
      routerProps: import('react-router').RouteComponentProps,
    ) => boolean;
  }

  // eslint-disable-next-line react/prefer-stateless-function
  class ScrollContainer extends React.Component<ScrollContainerProps> {}

  // Todo: ScrollContext exists in react-router-scroll-4 but we haven't used it
}
