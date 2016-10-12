import { expect } from 'chai';
import { shallow } from 'enzyme';

import LoadingIndicator from '../../../app/assets/javascripts/components/components/loading_indicator'

describe('<LoadingIndicator />', () => {
  it('renders text that indicates loading', () => {
    const wrapper = shallow(<LoadingIndicator />);
    expect(wrapper.text()).to.match(/loading/i);
  });
});
