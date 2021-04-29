import { connect } from 'react-redux';
import FavouriteToggle from '../components/favourite_toggle';
import { addFavouriteTags, removeFavouriteTags } from '../../../actions/favourite_tags';

const mapStateToProps = (state, { tag }) => ({
  isRegistered: state.getIn(['favourite_tags', 'tags']).some(t => t.get('name') === tag),
});

const mapDispatchToProps = dispatch => ({

  addFavouriteTags (tag, visibility) {
    dispatch(addFavouriteTags(tag, visibility));
  },

  removeFavouriteTags (tag) {
    dispatch(removeFavouriteTags(tag));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(FavouriteToggle);
