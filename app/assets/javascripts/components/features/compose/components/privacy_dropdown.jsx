import PureRenderMixin from 'react-addons-pure-render-mixin';
import { FormattedMessage } from 'react-intl';
import IconButton from '../../../components/icon_button';

const PrivacyDropdown = React.createClass({

  propTypes: {
    value: React.PropTypes.string.isRequired,
    onChange: React.PropTypes.func.isRequired
  },

  getInitialState () {
    return {
      open: false
    };
  },

  mixins: [PureRenderMixin],

  handleToggle () {
    this.setState({ open: !this.state.open });
  },

  handleClick (value, e) {
    e.preventDefault();
    this.setState({ open: false });
    this.props.onChange(value);
  },

  onGlobalClick (e) {
    if (e.target !== this.node && !this.node.contains(e.target) && this.state.open) {
      this.setState({ open: false });
    }
  },

  componentDidMount () {
    window.addEventListener('click', this.onGlobalClick);
    window.addEventListener('touchstart', this.onGlobalClick);
  },

  componentWillUnmount () {
    window.removeEventListener('click', this.onGlobalClick);
    window.removeEventListener('touchstart', this.onGlobalClick);
  },

  setRef (c) {
    this.node = c;
  },

  render () {
    const { value, onChange } = this.props;
    const { open } = this.state;

    const options = [
      { icon: 'globe', value: 'public', shortText: 'Public', longText: 'Anyone can see' },
      { icon: 'globe', value: 'unlisted', shortText: 'Unlisted', longText: 'Anyone can see' },
      { icon: 'lock', value: 'private', shortText: 'Private', longText: 'Followers can see' },
      { icon: 'send', value: 'direct', shortText: 'Direct', longText: 'Mentions can see' }
    ];

    const valueOption = options.find(item => item.value === value);

    return (
      <div ref={this.setRef} className={`privacy-dropdown ${open ? 'active' : ''}`}>
        <div className='privacy-dropdown__value'><IconButton icon={valueOption.icon} size={22} active={open} inverted onClick={this.handleToggle} /></div>
        <div className='privacy-dropdown__dropdown'>
          {options.map(item =>
            <div key={item.value} onClick={this.handleClick.bind(this, item.value)} className={`privacy-dropdown__option ${item.value === value ? 'active' : ''}`}>
              <div className='privacy-dropdown__option__icon'><i className={`fa fa-fw fa-${item.icon}`} /></div>
              <div className='privacy-dropdown__option__content'>
                <strong>{item.shortText}</strong>
                {item.longText}
              </div>
            </div>
          )}
        </div>
      </div>
    );
  }

});

export default PrivacyDropdown;
