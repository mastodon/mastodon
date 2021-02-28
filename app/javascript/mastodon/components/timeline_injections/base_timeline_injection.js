import React from 'react';
import ImmutablePureComponent from 'react-immutable-pure-component';
import classNames from 'classnames';

class BaseTimelineInjection extends ImmutablePureComponent {

  render() {
    return (<div className={classNames('status__wrapper', 'status__wrapper-public')}>
      <div className={classNames('status', 'status-public')}>
        Advertisement
      </div>
    </div>);
  }

}

export default BaseTimelineInjection;
