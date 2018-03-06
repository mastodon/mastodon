import { connect } from 'react-redux';
import TrendTags from '../components/trend_tags';
import { refreshTrendTags, toggleTrendTags } from '../../../actions/trend_tags';

const mapStateToProps = state => {
  return {
    trendTags: state.getIn(['trend_tags', 'tags', 'score']),
    visible: state.getIn(['trend_tags', 'visible']),
    favouriteTags: state.getIn(['favourite_tags', 'tags']),
  };
};

const mapDispatchToProps = dispatch => ({
  refreshTrendTags () {
    dispatch(refreshTrendTags());
  },
  onToggle () {
    dispatch(toggleTrendTags());
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(TrendTags);
