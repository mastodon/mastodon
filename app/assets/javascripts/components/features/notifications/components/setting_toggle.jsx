import ImmutablePropTypes from 'react-immutable-proptypes';
import Toggle from 'react-toggle';

const labelStyle = {
  display: 'block',
  lineHeight: '24px',
  verticalAlign: 'middle'
};

const labelSpanStyle = {
  display: 'inline-block',
  verticalAlign: 'middle',
  marginBottom: '14px',
  marginLeft: '8px',
  color: '#9baec8'
};

const SettingToggle = ({ settings, settingKey, label, onChange }) => (
  <label style={labelStyle}>
    <Toggle checked={settings.getIn(settingKey)} onChange={(e) => onChange(settingKey, e.target.checked)} />
    <span style={labelSpanStyle}>{label}</span>
  </label>
);

SettingToggle.propTypes = {
  settings: ImmutablePropTypes.map.isRequired,
  settingKey: React.PropTypes.array.isRequired,
  label: React.PropTypes.node.isRequired,
  onChange: React.PropTypes.func.isRequired
};

export default SettingToggle;
