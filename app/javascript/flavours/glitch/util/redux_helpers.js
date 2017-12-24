//  Merges react-redux props.
export function mergeProps (stateProps, dispatchProps, ownProps) {
  Object.assign({}, ownProps, {
    dispatch: Object.assign({}, dispatchProps, ownProps.dispatch || {}),
    state: Object.assign({}, stateProps, ownProps.state || {}),
  });
}
