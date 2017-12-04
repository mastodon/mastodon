import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { defineMessages, injectIntl } from 'react-intl';
import { setupListEditor } from '../../actions/lists';
import Account from './components/account';
import Search from './components/search';

const messages = defineMessages({

});

const mapStateToProps = state => ({
  title: state.getIn(['listEditor', 'title']),
  accountIds: state.getIn(['listEditor', 'accounts', 'items']),
});

const mapDispatchToProps = dispatch => ({
  onInitialize: listId => dispatch(setupListEditor(listId)),
});

@connect(mapStateToProps, mapDispatchToProps)
@injectIntl
export default class ListEditor extends ImmutablePureComponent {

  static propTypes = {
    listId: PropTypes.string.isRequired,
    onClose: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    onInitialize: PropTypes.func.isRequired,
    title: PropTypes.string.isRequired,
    accountIds: ImmutablePropTypes.list.isRequired,
  };

  componentDidMount () {
    const { onInitialize, listId } = this.props;
    onInitialize(listId);
  }

  render () {
    const { title, accountIds } = this.props;

    return (
      <div className='modal-root__modal list-editor'>
        <h4>{title}</h4>

        <Search />

        <div className='list-editor__accounts'>
          {accountIds.map(accountId => <Account key={accountId} accountId={accountId} />)}
        </div>
      </div>
    );
  }

}
