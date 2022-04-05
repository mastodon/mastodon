import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { injectIntl } from 'react-intl';
import { setupCircleAdder, resetCircleAdder } from '../../actions/circles';
import { createSelector } from 'reselect';
import Circle from './components/circle';
import Account from './components/account';
import NewCircleForm from '../circles/components/new_circle_form';
// hack

const getOrderedCircles = createSelector([state => state.get('circles')], circles => {
  if (!circles) {
    return circles;
  }

  return circles.toList().filter(item => !!item).sort((a, b) => a.get('title').localeCompare(b.get('title')));
});

const mapStateToProps = state => ({
  circleIds: getOrderedCircles(state).map(circle=>circle.get('id')),
});

const mapDispatchToProps = dispatch => ({
  onInitialize: accountId => dispatch(setupCircleAdder(accountId)),
  onReset: () => dispatch(resetCircleAdder()),
});

export default @connect(mapStateToProps, mapDispatchToProps)
@injectIntl
class CircleAdder extends ImmutablePureComponent {

  static propTypes = {
    accountId: PropTypes.string.isRequired,
    onClose: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    onInitialize: PropTypes.func.isRequired,
    onReset: PropTypes.func.isRequired,
    circleIds: ImmutablePropTypes.list.isRequired,
  };

  componentDidMount () {
    const { onInitialize, accountId } = this.props;
    onInitialize(accountId);
  }

  componentWillUnmount () {
    const { onReset } = this.props;
    onReset();
  }

  render () {
    const { accountId, circleIds } = this.props;

    return (
      <div className='modal-root__modal circle-adder'>
        <div className='circle-adder__account'>
          <Account accountId={accountId} />
        </div>

        <NewCircleForm />


        <div className='circle-adder__circles'>
          {circleIds.map(CircleId => <Circle key={CircleId} circleId={CircleId} />)}
        </div>
      </div>
    );
  }

}
