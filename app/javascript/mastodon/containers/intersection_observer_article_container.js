import { connect } from 'react-redux';

import { setHeight } from '../actions/height_cache';
import IntersectionObserverArticle from '../components/intersection_observer_article';

const makeMapStateToProps = (state, props) => ({
  cachedHeight: state.getIn(['height_cache', props.saveHeightKey, props.id]),
});

const mapDispatchToProps = (dispatch) => ({

  onHeightChange (key, id, height) {
    dispatch(setHeight(key, id, height));
  },

});

export default connect(makeMapStateToProps, mapDispatchToProps)(IntersectionObserverArticle);
