import PropTypes from 'prop-types';

import { injectIntl } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import spring from 'react-motion/lib/spring';

import { setupListEditor, clearListSuggestions, resetListEditor } from 'flavours/glitch/actions/lists';

import Motion from '../ui/util/optional_motion';

import EditListForm from './components/edit_list_form';
import AccountContainer from './containers/account_container';
import SearchContainer from './containers/search_container';


const mapStateToProps = state => ({
  accountIds: state.getIn(['listEditor', 'accounts', 'items']),
  searchAccountIds: state.getIn(['listEditor', 'suggestions', 'items']),
});

const mapDispatchToProps = dispatch => ({
  onInitialize: listId => dispatch(setupListEditor(listId)),
  onClear: () => dispatch(clearListSuggestions()),
  onReset: () => dispatch(resetListEditor()),
});

class ListEditor extends ImmutablePureComponent {

  static propTypes = {
    listId: PropTypes.string.isRequired,
    onClose: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    onInitialize: PropTypes.func.isRequired,
    onClear: PropTypes.func.isRequired,
    onReset: PropTypes.func.isRequired,
    accountIds: ImmutablePropTypes.list.isRequired,
    searchAccountIds: ImmutablePropTypes.list.isRequired,
  };

  componentDidMount () {
    const { onInitialize, listId } = this.props;
    onInitialize(listId);
  }

  componentWillUnmount () {
    const { onReset } = this.props;
    onReset();
  }

  render () {
    const { accountIds, searchAccountIds, onClear } = this.props;
    const showSearch = searchAccountIds.size > 0;

    return (
      <div className='modal-root__modal list-editor'>
        <EditListForm />

        <SearchContainer />

        <div className='drawer__pager'>
          <div className='drawer__inner list-editor__accounts'>
            {accountIds.map(accountId => <AccountContainer key={accountId} accountId={accountId} added />)}
          </div>

          {showSearch && <div role='button' tabIndex={-1} className='drawer__backdrop' onClick={onClear} />}

          <Motion defaultStyle={{ x: -100 }} style={{ x: spring(showSearch ? 0 : -100, { stiffness: 210, damping: 20 }) }}>
            {({ x }) =>
              (<div className='drawer__inner backdrop' style={{ transform: x === 0 ? null : `translateX(${x}%)`, visibility: x === -100 ? 'hidden' : 'visible' }}>
                {searchAccountIds.map(accountId => <AccountContainer key={accountId} accountId={accountId} />)}
              </div>)
            }
          </Motion>
        </div>
      </div>
    );
  }

}

export default connect(mapStateToProps, mapDispatchToProps)(injectIntl(ListEditor));
