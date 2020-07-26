import { connect } from 'react-redux';
import CircleDropdown from '../components/circle_dropdown';
import { changeComposeCircle } from '../../../actions/compose';

const mapStateToProps = state => {
  let value = state.getIn(['compose', 'circle_id']);
  value = value === null ? '' : value;

  return {
    value: value,
    visible: state.getIn(['compose', 'privacy']) === 'limited',
  };
};

const mapDispatchToProps = dispatch => ({

  onChange (value) {
    dispatch(changeComposeCircle(value));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(CircleDropdown);
