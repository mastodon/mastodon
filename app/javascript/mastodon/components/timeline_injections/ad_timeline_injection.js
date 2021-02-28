import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { defineMessages, injectIntl } from 'react-intl';
import TimelineInjectionLayout from './timeline_injection_layout';
import { googleAdClient, googleAdSlot, googleAdLayoutKey } from '../../initial_state';

const messages = defineMessages({
  advertisement: { id: 'advertisement.title', defaultMessage: 'Advertisement' },
});

export default @connect()
@injectIntl
class AdTimelineInjection extends React.PureComponent {

  static propTypes = {
    injectionId: PropTypes.string.isRequired,
    intl: PropTypes.object.isRequired,
  };

  componentDidMount() {
    (window.adsbygoogle = window.adsbygoogle || []).push({});
  }

  render() {
    const { injectionId, intl } = this.props;

    return (
      <TimelineInjectionLayout id={injectionId}>
        { intl.formatMessage(messages.advertisement) }
        <ins
          className='adsbygoogle'
          style={{ display: 'block', minWidth: '250px', width: '100%' }}
          data-ad-format='fluid'
          data-ad-layout-key={googleAdLayoutKey}
          data-ad-client={googleAdClient}
          data-ad-slot={googleAdSlot}
        />
      </TimelineInjectionLayout>
    );
  }

}
