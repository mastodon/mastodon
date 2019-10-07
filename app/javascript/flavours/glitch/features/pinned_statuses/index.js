import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { fetchPinnedStatuses } from 'flavours/glitch/actions/pin_statuses';
import Column from 'flavours/glitch/features/ui/components/column';
import ColumnBackButtonSlim from 'flavours/glitch/components/column_back_button_slim';
import StatusList from 'flavours/glitch/components/status_list';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';

const messages = defineMessages({
  heading: { id: 'column.pins', defaultMessage: 'Pinned toot' },
});

const mapStateToProps = state => ({
  statusIds: state.getIn(['status_lists', 'pins', 'items']),
  hasMore: !!state.getIn(['status_lists', 'pins', 'next']),
});

export default @connect(mapStateToProps)
@injectIntl
class PinnedStatuses extends ImmutablePureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    statusIds: ImmutablePropTypes.list.isRequired,
    intl: PropTypes.object.isRequired,
    hasMore: PropTypes.bool.isRequired,
    multiColumn: PropTypes.bool,
  };

  componentWillMount () {
    this.props.dispatch(fetchPinnedStatuses());
  }

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  setRef = c => {
    this.column = c;
  }

  render () {
    const { intl, statusIds, hasMore, multiColumn } = this.props;

    return (
      <Column bindToDocument={!multiColumn} icon='thumb-tack' heading={intl.formatMessage(messages.heading)} ref={this.setRef}>
        <ColumnBackButtonSlim />
        <StatusList
          statusIds={statusIds}
          scrollKey='pinned_statuses'
          hasMore={hasMore}
          bindToDocument={!multiColumn}
        />
      </Column>
    );
  }

}
