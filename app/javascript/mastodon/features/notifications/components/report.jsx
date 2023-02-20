import React, { Fragment } from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { defineMessages, FormattedMessage, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import AvatarOverlay from 'mastodon/components/avatar_overlay';
import RelativeTimestamp from 'mastodon/components/relative_timestamp';

const messages = defineMessages({
  openReport: { id: 'report_notification.open', defaultMessage: 'Open report' },
  other: { id: 'report_notification.categories.other', defaultMessage: 'Other' },
  spam: { id: 'report_notification.categories.spam', defaultMessage: 'Spam' },
  violation: { id: 'report_notification.categories.violation', defaultMessage: 'Rule violation' },
});

export default @injectIntl
class Report extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    report: ImmutablePropTypes.map.isRequired,
    hidden: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { intl, hidden, report, account } = this.props;

    if (!report) {
      return null;
    }

    if (hidden) {
      return (
        <Fragment>
          {report.get('id')}
        </Fragment>
      );
    }

    return (
      <div className='notification__report'>
        <div className='notification__report__avatar'>
          <AvatarOverlay account={report.get('target_account')} friend={account} />
        </div>

        <div className='notification__report__details'>
          <div>
            <RelativeTimestamp timestamp={report.get('created_at')} short={false} /> · <FormattedMessage id='report_notification.attached_statuses' defaultMessage='{count, plural, one {{count} post} other {{count} posts}} attached' values={{ count: report.get('status_ids').size }} />
            <br />
            <strong>{intl.formatMessage(messages[report.get('category')])}</strong>
          </div>

          <div className='notification__report__actions'>
            <a href={`/admin/reports/${report.get('id')}`} className='button' target='_blank' rel='noopener noreferrer'>{intl.formatMessage(messages.openReport)}</a>
          </div>
        </div>
      </div>
    );
  }

}
