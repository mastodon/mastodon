import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { injectIntl } from 'react-intl';
import TimelineInjectionLayout from './timeline_injection_layout';

export default @connect()
@injectIntl
class AdTimelineInjection extends React.PureComponent {

  static propTypes = {
    injectionId: PropTypes.string.isRequired,
  };

  componentDidMount() {

  }

  render() {
    return (
      <TimelineInjectionLayout>
        <div> Test </div>
      </TimelineInjectionLayout>
    );
  }

}
