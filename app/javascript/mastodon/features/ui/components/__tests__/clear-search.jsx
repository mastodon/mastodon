import React from 'react';

import { MemoryRouter } from 'react-router-dom';

import { render, fireEvent, screen } from '@testing-library/react';

import ColumnLink from '../column_link';

jest.mock('mastodon/actions/search', () => ({
  clearSearch: jest.fn(),
}));

const { clearSearch } = require('mastodon/actions/search');

jest.mock('mastodon/components/icon', () => {
  return ({ icon }) => <div>{icon}</div>;
});

describe('<ColumnLink />', () => {
  it('clears the search bar on explore click', () => {
    render(
      <MemoryRouter>
        <div>
          <ColumnLink
            to='/explore'
            heading='explore'
            icon='hashtag'
            text='Explore'
            title='Explore'
          />
        </div>
      </MemoryRouter>,
    );

    fireEvent.click(screen.getByTitle('Explore'));
    expect(clearSearch).toHaveBeenCalledTimes(1);
  });
});
