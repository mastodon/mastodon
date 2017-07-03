import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import IconButton from '../../../components/icon_button';
import Toggle from 'react-toggle';
import { injectIntl, defineMessages } from 'react-intl';

const messages = defineMessages({
  local_only_short: { id: 'advanced-options.local-only.short', defaultMessage: 'Local-only'},
  local_only_long: { id: 'advanced-options.local-only.long', defaultMessage: 'bla' },
  advanced_options_icon_title: { id: 'advanced_options.icon_title', defaultMessage: 'Advanced options' },
});

const iconStyle = {
  height: null,
  lineHeight: '27px',
};

@injectIntl
export default class AdvancedOptionsDropdown extends React.PureComponent {
  static propTypes = {
    values: ImmutablePropTypes.contains({
      do_not_federate: PropTypes.bool.isRequired,
    }).isRequired,
    onChange: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  onToggleDropdown = () => {
      this.setState({ open: !this.state.open });
  };

  onGlobalClick = (e) => {
    if (e.target !== this.node && !this.node.contains(e.target) && this.state.open) {
      this.setState({ open: false });
    }
  }

  componentDidMount () {
    window.addEventListener('click', this.onGlobalClick);
    window.addEventListener('touchstart', this.onGlobalClick);
  }

  componentWillUnmount () {
    window.removeEventListener('click', this.onGlobalClick);
    window.removeEventListener('touchstart', this.onGlobalClick);
  }

  state = {
    open: false,
  };

  handleClick = (e) => {
    const option = e.currentTarget.getAttribute('data-index');
    e.preventDefault();
    this.props.onChange(option);
  }

  toggleHandler(option) {
    return () => this.props.onChange(option);
  }

  setRef = (c) => {
    this.node = c;
  }

  render () {
    const { open } = this.state;
    const { intl, values } = this.props;

    const options = [
      { icon: 'wifi', shortText: messages.local_only_short,  longText: messages.local_only_long, key: 'do_not_federate' },
    ];

    const anyEnabled = values.some((enabled) => enabled); 
    const optionElems = options.map((option) => {
      const active = values.get(option.key) ? 'active' : '';
      return (
        <div role='button' className={`advanced-options-dropdown__option`} key={option.key} >
          <div className='advanced-options-dropdown__option__toggle'>
            <Toggle checked={active} onChange={this.toggleHandler(option.key)} />
          </div>
          <div className='advanced-options-dropdown__option__content'>
            <strong>{intl.formatMessage(option.shortText)}</strong>
            {intl.formatMessage(option.longText)}
          </div>
        </div>
      );
    });

    return <div ref={this.setRef} className={`advanced-options-dropdown ${open ?  'open' : ''} ${anyEnabled ? 'active' : ''} `}>
      <div className='advanced-options-dropdown__value'>
        <IconButton className='advanced-options-dropdown__value'
          title={intl.formatMessage(messages.advanced_options_icon_title)}
          icon='ellipsis-h' active={open || anyEnabled}
          size={18}
          style={iconStyle}
          onClick={this.onToggleDropdown} />
      </div>
      <div className='advanced-options-dropdown__dropdown'>
        {optionElems}
      </div>
    </div>;
  }
}