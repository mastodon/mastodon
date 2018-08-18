import { connect } from 'react-redux';
import TrendTags from '../components/trend_tags';
import { refreshTrendTags,
  refreshTrendTagsHistory,
  toggleTrendTags,
} from '../../../actions/trend_tags';

const mapStateToProps = state => {
  return {
    trendTags: state.getIn(['trend_tags', 'tags', 'score']),
    trendTagsHistory: state.getIn(['trend_tags', 'history']),
    visible: state.getIn(['trend_tags', 'visible']),
    favouriteTags: state.getIn(['favourite_tags', 'tags']),
  };
};

const mapDispatchToProps = dispatch => ({
  refreshTrendTags () {
    dispatch(refreshTrendTags());
    dispatch(refreshTrendTagsHistory());
  },
  onToggle () {
    dispatch(toggleTrendTags());
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(TrendTags);
