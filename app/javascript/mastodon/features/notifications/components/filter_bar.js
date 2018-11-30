import React from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';

export default class FilterBar extends React.PureComponent {

  static propTypes = {
    selectFilter: PropTypes.func.isRequired,
    selectedFilter: PropTypes.string.isRequired,
  };

  onClick (notificationType) {
    return () => this.props.selectFilter(notificationType);
  }

  render () {
    const { selectedFilter } = this.props;
    return (
      <div className='notification__filter-bar'>
        <button
          className={selectedFilter === 'all' ? 'active' : ''}
          onClick={this.onClick('all')}
        >
          <FormattedMessage
            id='notifications.filter.all'
            defaultMessage='All'
          />
        </button>
        <button
          className={selectedFilter === 'mention' ? 'active' : ''}
          onClick={this.onClick('mention')}
        >
          <FormattedMessage
            id='notifications.filter.mentions'
            defaultMessage='Mentions'
          />
        </button>
        <button
          className={selectedFilter === 'favourite' ? 'active' : ''}
          onClick={this.onClick('favourite')}
        >
          <FormattedMessage
            id='notifications.filter.favourites'
            defaultMessage='Favourites'
          />
        </button>
        <button
          className={selectedFilter === 'reblog' ? 'active' : ''}
          onClick={this.onClick('reblog')}
        >
          <FormattedMessage
            id='notifications.filter.boosts'
            defaultMessage='Boosts'
          />
        </button>
        <button
          className={selectedFilter === 'follow' ? 'active' : ''}
          onClick={this.onClick('follow')}
        >
          <FormattedMessage
            id='notifications.filter.follows'
            defaultMessage='Follows'
          />
        </button>
      </div>
    );
  }

}
