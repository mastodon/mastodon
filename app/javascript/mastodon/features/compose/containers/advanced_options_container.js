import { connect } from 'react-redux';
import AdvancedOptionsDropdown from '../components/advanced_options_dropdown';
import { changeComposeAdvancedOption } from '../../../actions/compose';

const mapStateToProps = state => ({
  values: state.getIn(['compose', 'advanced_options']),
});

const mapDispatchToProps = dispatch => ({

  onChange (option) {
    dispatch(changeComposeAdvancedOption(option));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(AdvancedOptionsDropdown);