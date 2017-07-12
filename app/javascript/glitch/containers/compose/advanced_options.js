//  Package imports  //
import { connect } from 'react-redux';

//  Mastodon imports  //
import { changeComposeAdvancedOption } from '../../../mastodon/actions/compose';

//  Our imports  //
import ComposeAdvancedOptions from '../../components/compose/advanced_options';

const mapStateToProps = state => ({
  values: state.getIn(['compose', 'advanced_options']),
});

const mapDispatchToProps = dispatch => ({

  onChange (option) {
    dispatch(changeComposeAdvancedOption(option));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(ComposeAdvancedOptions);
