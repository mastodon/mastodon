import { connect } from 'react-redux';
import StatusMediaGallery from '../components/status_media_gallery';
import { makeGetStatus } from '../selectors';

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();

  const mapStateToProps = (state, props) => ({
    card: state.getIn(['cards', props.id]),
    status: getStatus(state, props.id),
  });

  return mapStateToProps;
};

export default connect(makeMapStateToProps)(StatusMediaGallery);
