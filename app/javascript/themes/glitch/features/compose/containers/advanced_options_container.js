//  Package imports.
import { connect } from 'react-redux';

//  Our imports.
import { toggleComposeAdvancedOption } from 'themes/glitch/actions/compose';
import ComposeAdvancedOptions from '../components/advanced_options';

const mapStateToProps = state => ({
  values: state.getIn(['compose', 'advanced_options']),
});

const mapDispatchToProps = dispatch => ({

  onChange (option) {
    dispatch(toggleComposeAdvancedOption(option));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(ComposeAdvancedOptions);
