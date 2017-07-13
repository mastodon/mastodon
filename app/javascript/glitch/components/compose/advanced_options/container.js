//  Package imports  //
import { connect } from 'react-redux';

//  Mastodon imports  //
import { toggleComposeAdvancedOption } from '../../../../mastodon/actions/compose';

//  Our imports  //
import ComposeAdvancedOptions from '.';

const mapStateToProps = state => ({
  values: state.getIn(['compose', 'advanced_options']),
});

const mapDispatchToProps = dispatch => ({

  onChange (option) {
    dispatch(toggleComposeAdvancedOption(option));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(ComposeAdvancedOptions);
