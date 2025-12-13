declare namespace React {
  interface HTMLAttributes<T> extends AriaAttributes, DOMAttributes<T> {
    // Add inert attribute support, which is only in React 19.2. See: https://github.com/facebook/react/pull/24730
    inert?: '';
  }
}
