/*

`<ComposeAdvancedOptionsContainer>`
===================================

This container connects `<ComposeAdvancedOptions>` to the Redux store.

*/

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

Imports:
--------

*/

//  Package imports  //
import { connect } from 'react-redux';

//  Mastodon imports  //
import { toggleComposeAdvancedOption } from '../../../../mastodon/actions/compose';

//  Our imports  //
import ComposeAdvancedOptions from '.';

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

State mapping:
--------------

The `mapStateToProps()` function maps various state properties to the
props of our component. The only property we care about is
`compose.advanced_options`.

*/

const mapStateToProps = state => ({
  values: state.getIn(['compose', 'advanced_options']),
});

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

Dispatch mapping:
-----------------

The `mapDispatchToProps()` function maps dispatches to our store to the
various props of our component. We just need to provide a dispatch for
when an advanced option toggle changes.

*/

const mapDispatchToProps = dispatch => ({

  onChange (option) {
    dispatch(toggleComposeAdvancedOption(option));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(ComposeAdvancedOptions);
