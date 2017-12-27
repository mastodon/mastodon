import { injectIntl } from 'react-intl';
import { connect } from 'react-redux';

//  Merges react-redux props.
export function mergeProps (stateProps, dispatchProps, ownProps) {
  Object.assign({}, ownProps, {
    dispatch: Object.assign({}, dispatchProps, ownProps.dispatch || {}),
    state: Object.assign({}, stateProps, ownProps.state || {}),
  });
}

//  Connects a component.
export function wrap (Component, mapStateToProps, mapDispatchToProps, options) {
  const withIntl = typeof options === 'object' ? options.withIntl : !!options;
  return (withIntl ? injectIntl : i => i)(connect(mapStateToProps, mapDispatchToProps, mergeProps)(Component));
}
