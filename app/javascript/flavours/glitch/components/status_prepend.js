//  Package imports  //
import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage } from 'react-intl';
import Icon from 'flavours/glitch/components/icon';
import { me } from 'flavours/glitch/util/initial_state';

export default class StatusPrepend extends React.PureComponent {

  static propTypes = {
    type: PropTypes.string.isRequired,
    account: ImmutablePropTypes.map.isRequired,
    parseClick: PropTypes.func.isRequired,
    notificationId: PropTypes.number,
  };

  handleClick = (e) => {
    const { account, parseClick } = this.props;
    parseClick(e, `/accounts/${account.get('id')}`);
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
    case 'featured':
      return (
        <FormattedMessage id='status.pinned' defaultMessage='Pinned toot' />
      );
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
    case 'poll':
      if (me === account.get('id')) {
        return (
          <FormattedMessage
            id='notification.own_poll'
            defaultMessage='Your poll has ended'
          />
        );
      } else {
        return (
          <FormattedMessage
            id='notification.poll'
            defaultMessage='A poll you have voted in has ended'
          />
        );
      }
    }
    return null;
  }

  render () {
    const { Message } = this;
    const { type } = this.props;

    return !type ? null : (
      <aside className={type === 'reblogged_by' || type === 'featured' ? 'status__prepend' : 'notification__message'}>
        <div className={type === 'reblogged_by' || type === 'featured' ? 'status__prepend-icon-wrapper' : 'notification__favourite-icon-wrapper'}>
          <Icon
            className={`status__prepend-icon ${type === 'favourite' ? 'star-icon' : ''}`}
            id={type === 'favourite' ? 'star' : (type === 'featured' ? 'thumb-tack' : (type === 'poll' ? 'tasks' : 'retweet'))}
          />
        </div>
        <Message />
      </aside>
    );
  }

}
