import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';

class SettingText extends React.PureComponent {

  constructor (props, context) {
    super(props, context);
    this.handleChange = this.handleChange.bind(this);
  }

  handleChange (e) {
    this.props.onChange(this.props.settingKey, e.target.value)
  }

  render () {
    const { settings, settingKey, label } = this.props;

    return (
      <input
        className='setting-text'
        value={settings.getIn(settingKey)}
        onChange={this.handleChange}
        placeholder={label}
      />
    );
  }

}

SettingText.propTypes = {
  settings: ImmutablePropTypes.map.isRequired,
  settingKey: PropTypes.array.isRequired,
  label: PropTypes.string.isRequired,
  onChange: PropTypes.func.isRequired
};

export default SettingText;
