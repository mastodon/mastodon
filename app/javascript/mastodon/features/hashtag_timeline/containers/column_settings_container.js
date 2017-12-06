import { connect } from 'react-redux';
import ColumnSettings from '../components/column_settings';
import { changeSetting, saveSettings } from '../../../actions/settings';
import { addFavouriteTags, removeFavouriteTags } from '../../../actions/favourite_tags';

const mapStateToProps = (state, { tag }) => ({
  settings: state.getIn(['settings', 'tag']),
  isRegistered: state.getIn(['favourite_tags', 'tags']).some(t => t.get('name') === tag),
});

const mapDispatchToProps = dispatch => ({

  onChange (tag, key, checked) {
    dispatch(changeSetting(['tag', `${tag}`, ...key], checked));
  },

  onSave () {
    dispatch(saveSettings());
  },

  addFavouriteTags (tag, visibility) {
    dispatch(addFavouriteTags(tag, visibility));
  },
  
  removeFavouriteTags (tag) {
    dispatch(removeFavouriteTags(tag));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(ColumnSettings);
