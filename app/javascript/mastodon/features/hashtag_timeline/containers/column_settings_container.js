import { connect } from 'react-redux';
import ColumnSettings from '../components/column_settings';
import { changeColumnParams } from '../../../actions/columns';
import api from '../../../api';
import { showAlert } from '../../../actions/alerts';
import { defineMessages } from 'react-intl';

const messages = defineMessages({
  tooManyHashtags: { id: 'column_settings.too_many_hashtags', defaultMessage: 'A maximum of 4 hashtags can be added to a filter.' },
});

const mapStateToProps = (state, { columnId }) => {
  const columns = state.getIn(['settings', 'columns']);
  const index   = columns.findIndex(c => c.get('uuid') === columnId);

  if (!(columnId && index >= 0)) {
    return {};
  }

  return {
    settings: columns.get(index).get('params'),
    onLoad (value) {
      return api(() => state).get('/api/v2/search', { params: { q: value, type: 'hashtags' } }).then(response => {
        return (response.data.hashtags || []).map((tag) => {
          return { value: tag.name, label: `#${tag.name}` };
        });
      });
    },
  };
};

const mapDispatchToProps = (dispatch, { columnId }) => ({
  onChange (key, value) {
    if (value.length > 4) {
      dispatch(showAlert(undefined, messages.tooManyHashtags));
    } else {
      dispatch(changeColumnParams(columnId, key, value));
    }
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(ColumnSettings);
