import React from 'react';
import { mount } from 'enzyme';
import Column from '../column';
import ColumnHeader from '../column_header';

describe('<Column />', () => {
  describe('<ColumnHeader /> click handler', () => {
    it('runs the scroll animation if the column contains scrollable content', () => {
      const wrapper = mount(
        <Column heading='notifications'>
          <div className='scrollable' />
        </Column>,
      );
      const scrollToMock = jest.fn();
      wrapper.find(Column).find('.scrollable').getDOMNode().scrollTo = scrollToMock;
      wrapper.find(ColumnHeader).find('button').simulate('click');
      expect(scrollToMock).toHaveBeenCalledWith({ behavior: 'smooth', top: 0 });
    });

    it('does not try to scroll if there is no scrollable content', () => {
      const wrapper = mount(<Column heading='notifications' />);
      wrapper.find(ColumnHeader).find('button').simulate('click');
    });
  });
});
