import { expect } from 'chai';
import { mount } from 'enzyme';
import sinon from 'sinon';

import Column from '../../../../../../app/assets/javascripts/components/features/ui/components/column';
import ColumnHeader from '../../../../../../app/assets/javascripts/components/features/ui/components/column_header';

describe('<Column />', () => {
  describe('<ColumnHeader /> click handler', () => {
    beforeEach(() => {
      global.requestAnimationFrame = sinon.spy();
    });

    it('runs the scroll animation if the column contains scrollable content', () => {
      const wrapper = mount(
        <Column heading="notifications">
          <div className="scrollable" />
        </Column>
      );
      wrapper.find(ColumnHeader).simulate('click');
      expect(global.requestAnimationFrame.called).to.equal(true);
    });

    it('does not try to scroll if there is no scrollable content', () => {
      const wrapper = mount(<Column heading="notifications" />);
      wrapper.find(ColumnHeader).simulate('click');
      expect(global.requestAnimationFrame.called).to.equal(false);
    });
  });
});
