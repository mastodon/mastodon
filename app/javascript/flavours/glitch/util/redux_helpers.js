import { injectIntl } from 'react-intl';
import { connect } from 'react-redux';

//  Connects a component.
export function wrap (Component, mapStateToProps, mapDispatchToProps, options) {
  const withIntl = typeof options === 'object' ? options.withIntl : !!options;
  return (withIntl ? injectIntl : i => i)(connect(mapStateToProps, mapDispatchToProps)(Component));
}
