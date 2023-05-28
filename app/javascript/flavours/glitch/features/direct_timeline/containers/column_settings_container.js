import { connect } from 'react-redux';

import { changeSetting } from 'flavours/glitch/actions/settings';

import ColumnSettings from '../components/column_settings';

const mapStateToProps = state => ({
  settings: state.getIn(['settings', 'direct']),
});

const mapDispatchToProps = dispatch => ({

  onChange (path, checked) {
    dispatch(changeSetting(['direct', ...path], checked));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(ColumnSettings);
