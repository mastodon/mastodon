import { connect } from 'react-redux';
import UnlistedToggle from '../components/unlisted_toggle';
import { makeGetStatus } from '../../../selectors';
import { changeComposeListability } from '../../../actions/compose';

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();

  const mapStateToProps = state => {
    const status = getStatus(state, state.getIn(['compose', 'in_reply_to']));
    const me     = state.getIn(['compose', 'me']);

    return {
      isPrivate: state.getIn(['compose', 'private']),
      isUnlisted: state.getIn(['compose', 'unlisted']),
      isReplyToOther: status ? status.getIn(['account', 'id']) !== me : false
    };
  };

  return mapStateToProps;
};

const mapDispatchToProps = dispatch => ({

  onChangeListability (e) {
    dispatch(changeComposeListability(e.target.checked));
  }

});

export default connect(makeMapStateToProps, mapDispatchToProps)(UnlistedToggle);
