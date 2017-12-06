//  Package imports  //
import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage } from 'react-intl';

export default class StatusPrepend extends React.PureComponent {

  static propTypes = {
    type: PropTypes.string.isRequired,
    account: ImmutablePropTypes.map.isRequired,
    parseClick: PropTypes.func.isRequired,
    notificationId: PropTypes.number,
  };

  handleClick = (e) => {
    const { account, parseClick } = this.props;
    parseClick(e, `/accounts/${+account.get('id')}`);
  }

  Message = () => {
    const { type, account } = this.props;
    let link = (
      <a
        onClick={this.handleClick}
        href={account.get('url')}
        className='status__display-name'
      >
        <b
          dangerouslySetInnerHTML={{
            __html : account.get('display_name_html') || account.get('username'),
          }}
        />
      </a>
    );
    switch (type) {
    case 'reblogged_by':
      return (
        <FormattedMessage
          id='status.reblogged_by'
          defaultMessage='{name} boosted'
          values={{ name : link }}
        />
      );
    case 'favourite':
      return (
        <FormattedMessage
          id='notification.favourite'
          defaultMessage='{name} favourited your status'
          values={{ name : link }}
        />
      );
    case 'reblog':
      return (
        <FormattedMessage
          id='notification.reblog'
          defaultMessage='{name} boosted your status'
          values={{ name : link }}
        />
      );
    }
    return null;
  }

  render () {
    const { Message } = this;
    const { type } = this.props;

    return !type ? null : (
      <aside className={type === 'reblogged_by' ? 'status__prepend' : 'notification__message'}>
        <div className={type === 'reblogged_by' ? 'status__prepend-icon-wrapper' : 'notification__favourite-icon-wrapper'}>
          <i
            className={`fa fa-fw fa-${
              type === 'favourite' ? 'star star-icon' : 'retweet'
            } status__prepend-icon`}
          />
        </div>
        <Message />
      </aside>
    );
  }

}
