import React from 'react';
import { mount } from 'enzyme';
import Column from '../column';
import ColumnHeader from '../column_header';

describe('<Column />', () => {
  describe('<ColumnHeader /> click handler', () => {
    const originalRaf = global.requestAnimationFrame;

    beforeEach(() => {
      global.requestAnimationFrame = jest.fn();
    });

    afterAll(() => {
      global.requestAnimationFrame = originalRaf;
    });

    it('runs the scroll animation if the column contains scrollable content', () => {
      const wrapper = mount(
        <Column heading='notifications'>
          <div className='scrollable' />
        </Column>,
      );
      wrapper.find(ColumnHeader).find('button').simulate('click');
      expect(global.requestAnimationFrame.mock.calls.length).toEqual(1);
    });

    it('does not try to scroll if there is no scrollable content', () => {
      const wrapper = mount(<Column heading='notifications' />);
      wrapper.find(ColumnHeader).find('button').simulate('click');
      expect(global.requestAnimationFrame.mock.calls.length).toEqual(0);
    });
  });
});
