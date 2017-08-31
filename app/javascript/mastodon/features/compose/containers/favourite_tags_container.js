import { connect } from 'react-redux';
import FavouriteTags from '../components/favourite_tags';
import { refreshFavouriteTags, lockTagCompose } from '../../../actions/favourite_tags';

const mapStateToProps = state => {
  return {
    tags: state.getIn(['favourite_tags', 'tags']),
  };
};

const mapDispatchToProps = dispatch => ({
  refreshFavouriteTags () {
    dispatch(refreshFavouriteTags());
  },
  onLockTag (tag, visibility) {
    dispatch(lockTagCompose(tag, visibility));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(FavouriteTags);
