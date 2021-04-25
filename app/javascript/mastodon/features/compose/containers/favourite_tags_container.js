import { connect } from 'react-redux';
import FavouriteTags from '../components/favourite_tags';
import { refreshFavouriteTags, toggleFavouriteTags, lockTagCompose } from '../../../actions/favourite_tags';

const mapStateToProps = state => {
  return {
    tags: state.getIn(['favourite_tags', 'tags']),
    visible: state.getIn(['favourite_tags', 'visible']),
  };
};

const mapDispatchToProps = dispatch => ({
  refreshFavouriteTags () {
    dispatch(refreshFavouriteTags());
  },
  onToggle () {
    dispatch(toggleFavouriteTags());
  },
  onLockTag (tag, visibility) {
    dispatch(lockTagCompose(tag, visibility));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(FavouriteTags);
