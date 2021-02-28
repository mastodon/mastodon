import React from 'react';
import PropTypes from 'prop-types';
import Bundle from '../../features/ui/components/bundle';
import { AdTimelineInjection } from '../../features/ui/util/async-components';
import { AD_INJECTION_COMPONENT } from '../../initial_state';

const INJECTION_COMPONENTS = {};
INJECTION_COMPONENTS[AD_INJECTION_COMPONENT] = AdTimelineInjection;

class RootTimelineInjection extends React.PureComponent {

  static propTypes = {
    type: PropTypes.string.isRequired,
    props: PropTypes.object,
  }

  renderLoading = () => {
    return <div />;
  }

  renderError = () => {
    return <div />;
  }

  render() {
    const { type, props } = this.props;

    return (
      <div>
        <Bundle
          fetchComponent={INJECTION_COMPONENTS[type]}
          loading={this.renderLoading}
          error={this.renderError}
          renderDelay={150}
        >
          {
            (Component) => (
              <Component
                injectionId={type}
                {...props}
              />
            )
          }
        </Bundle>
      </div>
    );
  }

}

export default RootTimelineInjection;
