import { expect } from 'chai';
import { shallow, mount } from 'enzyme';
import sinon from 'sinon';
import React from 'react';
import DropdownMenu from '../../../app/javascript/mastodon/components/dropdown_menu';
import Dropdown, { DropdownTrigger, DropdownContent } from 'react-simple-dropdown';

describe('<DropdownMenu />', () => {
  const icon = 'my-icon';
  const size = 123;
  const action = sinon.spy();

  const items = [
    { text: 'first item',  action: action, href: '/some/url' },
    { text: 'second item', action: 'noop' },
  ];
  const wrapper = shallow(<DropdownMenu icon={icon} items={items} size={size} />);

  it('contains one <Dropdown />', () => {
    expect(wrapper).to.have.exactly(1).descendants(Dropdown);
  });

  it('contains one <DropdownTrigger />', () => {
    expect(wrapper.find(Dropdown)).to.have.exactly(1).descendants(DropdownTrigger);
  });

  it('contains one <DropdownContent />', () => {
    expect(wrapper.find(Dropdown)).to.have.exactly(1).descendants(DropdownContent);
  });

  it('uses props.size for <DropdownTrigger /> style values', () => {
    ['font-size', 'width', 'line-height'].map((property) => {
      expect(wrapper.find(DropdownTrigger)).to.have.style(property, `${size}px`);
    });
  });

  it('uses props.icon as icon class name', () => {
    expect(wrapper.find(DropdownTrigger).find('i')).to.have.className(`fa-${icon}`);
  });

  it('is not expanded by default', () => {
    expect(wrapper.state('expanded')).to.be.equal(false);
  });

  it('does not render the list elements if not expanded', () => {
    const lis = wrapper.find(DropdownContent).find('li');
    expect(lis.length).to.be.equal(0);
  });

  it('sets expanded to true when clicking the trigger', () => {
    const wrapper = mount(<DropdownMenu icon={icon} items={items} size={size} />);
    wrapper.find(DropdownTrigger).first().simulate('click');
    expect(wrapper.state('expanded')).to.be.equal(true);
  });

  // Error: ReactWrapper::state() can only be called on the root
  /*it('sets expanded to false when clicking outside', () => {
    const wrapper = mount((
      <div>
        <DropdownMenu icon={icon} items={items} size={size} />
        <span />
      </div>
    ));

    wrapper.find(DropdownTrigger).first().simulate('click');
    expect(wrapper.find(DropdownMenu).first().state('expanded')).to.be.equal(true);

    wrapper.find('span').first().simulate('click');
    expect(wrapper.find(DropdownMenu).first().state('expanded')).to.be.equal(false);
  })*/

  it('renders list elements for each props.items if expanded', () => {
    const wrapper = mount(<DropdownMenu icon={icon} items={items} size={size} />);
    wrapper.find(DropdownTrigger).first().simulate('click');
    const lis = wrapper.find(DropdownContent).find('li');
    expect(lis.length).to.be.equal(items.length);
  });

  it('uses the href passed in via props.items', () => {
    wrapper
      .find(DropdownContent).find('li a')
      .forEach((a, i) => expect(a).to.have.attr('href', items[i].href));
  });

  it('uses the text passed in via props.items', () => {
    wrapper
      .find(DropdownContent).find('li a')
      .forEach((a, i) => expect(a).to.have.text(items[i].text));
  });

  it('uses the action passed in via props.items as click handler', () => {
    const wrapper = mount(<DropdownMenu icon={icon} items={items} size={size} />);
    wrapper.find(DropdownTrigger).first().simulate('click');
    wrapper.find(DropdownContent).find('li a').first().simulate('click');
    expect(action.calledOnce).to.equal(true);
  });
});
