import { connect } from 'react-redux';

import { changeSetting } from 'mastodon/actions/settings';

import ColumnSettings from '../components/column_settings';

const mapStateToProps = (state) => {
  return {
    settings: state.getIn(['settings', 'firehose']),
  };
};

const mapDispatchToProps = (dispatch) => {
  return {
    onChange (key, checked) {
      dispatch(changeSetting(['firehose', ...key], checked));
    },
  };
};

export default connect(mapStateToProps, mapDispatchToProps)(ColumnSettings);
