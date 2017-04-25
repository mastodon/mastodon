import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Toggle from 'react-toggle';

const SettingToggle = ({ settings, settingKey, label, onChange, htmlFor = '' }) => (
  <label htmlFor={htmlFor} className='setting-toggle__label'>
    <Toggle checked={settings.getIn(settingKey)} onChange={(e) => onChange(settingKey, e.target.checked)} />
    <span className='setting-toggle'>{label}</span>
  </label>
);

SettingToggle.propTypes = {
  settings: ImmutablePropTypes.map.isRequired,
  settingKey: PropTypes.array.isRequired,
  label: PropTypes.node.isRequired,
  onChange: PropTypes.func.isRequired,
  htmlFor: PropTypes.string
};

export default SettingToggle;
