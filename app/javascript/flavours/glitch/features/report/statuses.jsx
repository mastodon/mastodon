import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

import { OrderedSet } from 'immutable';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import Button from 'flavours/glitch/components/button';
import { LoadingIndicator } from 'flavours/glitch/components/loading_indicator';
import StatusCheckBox from 'flavours/glitch/features/report/containers/status_check_box_container';


const mapStateToProps = (state, { accountId }) => ({
  availableStatusIds: OrderedSet(state.getIn(['timelines', `account:${accountId}:with_replies`, 'items'])),
  isLoading: state.getIn(['timelines', `account:${accountId}:with_replies`, 'isLoading']),
});

class Statuses extends PureComponent {

  static propTypes = {
    onNextStep: PropTypes.func.isRequired,
    accountId: PropTypes.string.isRequired,
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
      <>
        <h3 className='report-dialog-modal__title'><FormattedMessage id='report.statuses.title' defaultMessage='Are there any posts that back up this report?' /></h3>
        <p className='report-dialog-modal__lead'><FormattedMessage id='report.statuses.subtitle' defaultMessage='Select all that apply' /></p>

        <div className='report-dialog-modal__statuses'>
          {isLoading ? <LoadingIndicator /> : availableStatusIds.union(selectedStatusIds).map(statusId => (
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
      </>
    );
  }

}

export default connect(mapStateToProps)(Statuses);
