import React from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';

export default class FilterBar extends React.PureComponent {

  // static propTypes = {
  //   onClick: PropTypes.func.isRequired,
  //   selectedFilter: PropTypes.string.isRequired
  // };

  render () {
    const { selectedFilter } = this.props
    return (
      <div className='notification__filter-bar'>
        <button
          className={selectedFilter === 'all' ? 'active' : ''}
          onClick={() => console.log('all')}
        >
          <FormattedMessage
            id='notifications.filter.all'
            defaultMessage='All'
          />
        </button>
        <button
          className={selectedFilter === 'mentions' ? 'active' : ''}
          onClick={() => console.log('mentions')}
        >
          <FormattedMessage
            id='notifications.filter.mentions'
            defaultMessage='Mentions'
          />
        </button>
        <button
          className={selectedFilter === 'favourites' ? 'active' : ''}
          onClick={() => console.log('favourites')}
        >
          <FormattedMessage
            id='notifications.filter.favourites'
            defaultMessage='Favourites'
          />
        </button>
        <button
          className={selectedFilter === 'boosts' ? 'active' : ''}
          onClick={() => console.log('boosts')}
        >
          <FormattedMessage
            id='notifications.filter.boosts'
            defaultMessage='Boosts'
          />
        </button>
        <button
          className={selectedFilter === 'follows' ? 'active' : ''}
          onClick={() => console.log('follows')}
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
