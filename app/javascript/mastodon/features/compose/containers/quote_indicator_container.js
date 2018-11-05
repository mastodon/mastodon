import { connect } from 'react-redux';
import { cancelQuoteCompose } from '../../../actions/compose';
import { makeGetStatus } from '../../../selectors';
import QuoteIndicator from '../components/quote_indicator';

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();

  const mapStateToProps = state => ({
<<<<<<< HEAD
    status: getStatus(state, { id: state.getIn(['compose', 'quote_from']) }),
=======
    status: getStatus(state, state.getIn(['compose', 'quote_from'])),
>>>>>>> 057244329... [New] Implement a feature of quote
  });

  return mapStateToProps;
};

const mapDispatchToProps = dispatch => ({

  onCancel () {
    dispatch(cancelQuoteCompose());
  },

});

export default connect(makeMapStateToProps, mapDispatchToProps)(QuoteIndicator);
