import React from 'react';
import { render, fireEvent } from '@testing-library/react';

describe('Scrolls to the first element', () => {
  it('calls scrollIntoView() when "." key is pressed', () => {
    const refreshFeedMock = jest.fn();

    const Component = render(<div title='timeline' />).getByTitle('timeline');

    Component.addEventListener('keydown', handleKeyDown);

    fireEvent.keyDown(Component, { key: '.' });
    expect(refreshFeedMock).toHaveBeenCalledTimes(1);

    Component.removeEventListener('keydown', handleKeyDown);

    function handleKeyDown(event) {
      if (event.key === '.') {
        refreshFeedMock();
      }
    }
  });
});
