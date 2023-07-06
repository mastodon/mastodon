import PropTypes from 'prop-types';

import { injectIntl } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';
import { createSelector } from 'reselect';

import { setupListAdder, resetListAdder } from '../../actions/lists';
import NewListForm from '../lists/components/new_list_form';

import Account from './components/account';
import List from './components/list';
// hack

const getOrderedLists = createSelector([state => state.get('lists')], lists => {
  if (!lists) {
    return lists;
  }

  return lists.toList().filter(item => !!item).sort((a, b) => a.get('title').localeCompare(b.get('title')));
});

const mapStateToProps = state => ({
  listIds: getOrderedLists(state).map(list=>list.get('id')),
});

const mapDispatchToProps = dispatch => ({
  onInitialize: accountId => dispatch(setupListAdder(accountId)),
  onReset: () => dispatch(resetListAdder()),
});

class ListAdder extends ImmutablePureComponent {

  static propTypes = {
    accountId: PropTypes.string.isRequired,
    onClose: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    onInitialize: PropTypes.func.isRequired,
    onReset: PropTypes.func.isRequired,
    listIds: ImmutablePropTypes.list.isRequired,
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
    const { accountId, listIds } = this.props;

    return (
      <div className='modal-root__modal list-adder'>
        <div className='list-adder__account'>
          <Account accountId={accountId} />
        </div>

        <NewListForm />


        <div className='list-adder__lists'>
          {listIds.map(ListId => <List key={ListId} listId={ListId} />)}
        </div>
      </div>
    );
  }

}

export default connect(mapStateToProps, mapDispatchToProps)(injectIntl(ListAdder));
