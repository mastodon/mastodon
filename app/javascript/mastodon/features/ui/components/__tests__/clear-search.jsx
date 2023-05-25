import React from 'react';

import { MemoryRouter } from 'react-router-dom';

import { render, fireEvent, screen } from '@testing-library/react';

import ColumnLink from '../column_link';

describe('<ColumnLink />', () => {
  it('clears the search bar on explore click', () => {
    const clearSearchMock = jest.fn();
    render(
      <MemoryRouter>
        <div>
          <ColumnLink
            to='/explore'
            heading='explore'
            icon='hashtag'
            text='Explore'
            title='Explore'
            onClick={clearSearchMock}
          />
        </div>
      </MemoryRouter>,
    );

    fireEvent.click(screen.getByTitle('Explore'));
    expect(clearSearchMock).toHaveBeenCalledTimes(1);
  });
});
