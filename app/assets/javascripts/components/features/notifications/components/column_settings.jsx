import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage } from 'react-intl';
import ColumnCollapsable from '../../../components/column_collapsable';
import SettingToggle from './setting_toggle';

const outerStyle = {
  background: '#373b4a',
  padding: '15px'
};

const sectionStyle = {
  cursor: 'default',
  display: 'block',
  fontWeight: '500',
  color: '#9baec8',
  marginBottom: '10px'
};

const rowStyle = {

};

const ColumnSettings = React.createClass({

  propTypes: {
    settings: ImmutablePropTypes.map.isRequired,
    onChange: React.PropTypes.func.isRequired,
    onSave: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    const { settings, onChange, onSave } = this.props;

    const alertStr = <FormattedMessage id='notifications.column_settings.alert' defaultMessage='Desktop notifications' />;
    const showStr  = <FormattedMessage id='notifications.column_settings.show' defaultMessage='Show in column' />;

    return (
      <ColumnCollapsable icon='sliders' fullHeight={458} onCollapse={onSave}>
        <div style={outerStyle}>
          <span style={sectionStyle}><FormattedMessage id='notifications.column_settings.follow' defaultMessage='New followers:' /></span>

          <div style={rowStyle}>
            <SettingToggle settings={settings} settingKey={['alerts', 'follow']} onChange={onChange} label={alertStr} />
            <SettingToggle settings={settings} settingKey={['shows', 'follow']} onChange={onChange} label={showStr} />
          </div>

          <span style={sectionStyle}><FormattedMessage id='notifications.column_settings.favourite' defaultMessage='Favourites:' /></span>

          <div style={rowStyle}>
            <SettingToggle settings={settings} settingKey={['alerts', 'favourite']} onChange={onChange} label={alertStr} />
            <SettingToggle settings={settings} settingKey={['shows', 'favourite']} onChange={onChange} label={showStr} />
          </div>

          <span style={sectionStyle}><FormattedMessage id='notifications.column_settings.mention' defaultMessage='Mentions:' /></span>

          <div style={rowStyle}>
            <SettingToggle settings={settings} settingKey={['alerts', 'mention']} onChange={onChange} label={alertStr} />
            <SettingToggle settings={settings} settingKey={['shows', 'mention']} onChange={onChange} label={showStr} />
          </div>

          <span style={sectionStyle}><FormattedMessage id='notifications.column_settings.reblog' defaultMessage='Boosts:' /></span>

          <div style={rowStyle}>
            <SettingToggle settings={settings} settingKey={['alerts', 'reblog']} onChange={onChange} label={alertStr} />
            <SettingToggle settings={settings} settingKey={['shows', 'reblog']} onChange={onChange} label={showStr} />
          </div>
        </div>
      </ColumnCollapsable>
    );
  }

});

export default ColumnSettings;
