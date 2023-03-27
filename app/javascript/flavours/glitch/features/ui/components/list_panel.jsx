import React from 'react';
import PropTypes from 'prop-types';
import { createSelector } from 'reselect';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';
import { fetchLists } from 'flavours/glitch/actions/lists';
import ColumnLink from './column_link';

const getOrderedLists = createSelector([state => state.get('lists')], lists => {
  if (!lists) {
    return lists;
  }

  return lists.toList().filter(item => !!item).sort((a, b) => a.get('title').localeCompare(b.get('title'))).take(4);
});

const mapStateToProps = state => ({
  lists: getOrderedLists(state),
});

class ListPanel extends ImmutablePureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    lists: ImmutablePropTypes.list,
  };

  componentDidMount () {
    const { dispatch } = this.props;
    dispatch(fetchLists());
  }

  render () {
    const { lists } = this.props;

    if (!lists || lists.isEmpty()) {
      return null;
    }

    return (
      <div className='list-panel'>
        <hr />

        {lists.map(list => (
          <ColumnLink icon='list-ul' key={list.get('id')} strict text={list.get('title')} to={`/lists/${list.get('id')}`} transparent />
        ))}
      </div>
    );
  }

}

export default withRouter(connect(mapStateToProps)(ListPanel));
