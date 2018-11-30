import React from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';

export default class FilterBar extends React.PureComponent {

  // static propTypes = {
  //   onClick: PropTypes.func.isRequired,
  // };

  render () {
    return (
      <div>
        <button
          onClick={() => console.log('all')}
        >
          <FormattedMessage
            id='notifications.filter.all'
            defaultMessage='All'
          />
        </button>
        <button
          onClick={() => console.log('mentions')}
        >
          <FormattedMessage
            id='notifications.filter.mentions'
            defaultMessage='Mentions'
          />
        </button>
        <button
          onClick={() => console.log('favourites')}
        >
          <FormattedMessage
            id='notifications.filter.favourites'
            defaultMessage='Favourites'
          />
        </button>
        <button
          onClick={() => console.log('Boosts')}
        >
          <FormattedMessage
            id='notifications.filter.Boosts'
            defaultMessage='Boosts'
          />
        </button>
        <button
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
