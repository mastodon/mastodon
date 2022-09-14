import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';
import StatusCheckBox from 'mastodon/features/report/containers/status_check_box_container';
import { OrderedSet } from 'immutable';
import { FormattedMessage } from 'react-intl';
import Button from 'mastodon/components/button';
import LoadingIndicator from 'mastodon/components/loading_indicator';
import { createSelector } from 'reselect';



const makeMapStateToProps = () => {
  // Not using createSelector because we allow state.get('statuses') to change without
  // recomputing the whole thing.
  const makeGetFilteredGroupTimeline = () => {
    let memoAccountId = undefined;
    let memoGroupTimeline = undefined;
    let memoFilteredGroupTimeline = undefined;

    return (state, { accountId, groupId }) => {
      const groupTimeline = groupId && state.getIn(['timelines', `group:${groupId}`, 'items']);
      if (!groupTimeline) {
        return null;
      }

      if (groupTimeline !== memoGroupTimeline || accountId !== memoAccountId) {
        memoGroupTimeline = groupTimeline;
        memoAccountId = accountId;
        memoFilteredGroupTimeline = groupTimeline.filter((id) => state.getIn(['statuses', id, 'account']) === accountId);
      }

      return memoFilteredGroupTimeline;
    };
  };

  const getAvailableStatusIds = createSelector([
    (_, { accountId }) => accountId,
    (_, { selectedStatusIds }) => selectedStatusIds,
    (state, { accountId }) => state.getIn(['timelines', `account:${accountId}:with_replies`, 'items']),
    makeGetFilteredGroupTimeline(),
  ], (accountId, selectedStatusIds, accountTimelineIds, groupTimelineIds) => {
    let statusIds = selectedStatusIds.union(accountTimelineIds);
    if (groupTimelineIds) {
      statusIds = statusIds.union(groupTimelineIds);
    }
    return statusIds.toList().sortBy(id => -id);
  });

  const mapStateToProps = (state, { accountId, selectedStatusIds, groupId }) => ({
    availableStatusIds: getAvailableStatusIds(state, { accountId, selectedStatusIds, groupId }),
    isLoading: state.getIn(['timelines', `account:${accountId}:with_replies`, 'isLoading']),
  });

  return mapStateToProps;
};

export default @connect(makeMapStateToProps)
class Statuses extends React.PureComponent {

  static propTypes = {
    onNextStep: PropTypes.func.isRequired,
    accountId: PropTypes.string.isRequired,
    groupId: PropTypes.string,
    availableStatusIds: ImmutablePropTypes.set.isRequired,
    selectedStatusIds: ImmutablePropTypes.set.isRequired,
    isLoading: PropTypes.bool,
    onToggle: PropTypes.func.isRequired,
  };

  handleNextClick = () => {
    const { onNextStep } = this.props;
    onNextStep('comment');
  };

  render () {
    const { availableStatusIds, selectedStatusIds, onToggle, isLoading } = this.props;

    return (
      <React.Fragment>
        <h3 className='report-dialog-modal__title'><FormattedMessage id='report.statuses.title' defaultMessage='Are there any posts that back up this report?' /></h3>
        <p className='report-dialog-modal__lead'><FormattedMessage id='report.statuses.subtitle' defaultMessage='Select all that apply' /></p>

        <div className='report-dialog-modal__statuses'>
          {isLoading ? <LoadingIndicator /> : availableStatusIds.map(statusId => (
            <StatusCheckBox
              id={statusId}
              key={statusId}
              checked={selectedStatusIds.includes(statusId)}
              onToggle={onToggle}
            />
          ))}
        </div>

        <div className='flex-spacer' />

        <div className='report-dialog-modal__actions'>
          <Button onClick={this.handleNextClick}><FormattedMessage id='report.next' defaultMessage='Next' /></Button>
        </div>
      </React.Fragment>
    );
  }

}
