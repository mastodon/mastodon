import ImmutablePropTypes from 'react-immutable-proptypes';

const style = {
  display: 'block',
  fontFamily: 'inherit',
  marginBottom: '10px',
  padding: '7px 0',
  boxSizing: 'border-box',
  width: '100%'
};

const SettingText = React.createClass({

  propTypes: {
    settings: ImmutablePropTypes.map.isRequired,
    settingKey: React.PropTypes.array.isRequired,
    label: React.PropTypes.string.isRequired,
    onChange: React.PropTypes.func.isRequired
  },

  handleChange (e) {
    this.props.onChange(this.props.settingKey, e.target.value)
  },

  render () {
    const { settings, settingKey, label } = this.props;

    return (
      <input
        style={style}
        className='setting-text'
        value={settings.getIn(settingKey)}
        onChange={this.handleChange}
        placeholder={label}
      />
    );
  }

});

export default SettingText;
