import React from 'react';
import classNames from 'classnames';

class TimelineInjectionLayout extends React.PureComponent {

  render() {
    return (
      <div className={classNames('status__wrapper', 'status__wrapper-public')}>
        <div className={classNames('status', 'card_layout', 'status-public')}>
          { this.props.children }
        </div>
      </div>
    );
  }

}

export default TimelineInjectionLayout;
