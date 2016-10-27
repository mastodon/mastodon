import { connect }            from 'react-redux';
import { makeGetAccount }     from '../../../selectors';
import Account                from '../components/account';

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = (state, props) => ({
    account: getAccount(state, props.id),
    me: state.getIn(['timelines', 'me'])
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch) => ({
  //
});

export default connect(makeMapStateToProps, mapDispatchToProps)(Account);
