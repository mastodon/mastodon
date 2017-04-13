import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ColumnCollapsable from '../../../components/column_collapsable';
import SettingToggle from './setting_toggle';

const messages = defineMessages({
  settings: { id: 'notifications.settings', defaultMessage: 'Column settings' }
});

const outerStyle = {
  padding: '15px'
};

const sectionStyle = {
  cursor: 'default',
  display: 'block',
  fontWeight: '500',
  marginBottom: '10px'
};

const rowStyle = {

};

const ColumnSettings = React.createClass({

  propTypes: {
    settings: ImmutablePropTypes.map.isRequired,
    intl: React.PropTypes.object.isRequired,
    onChange: React.PropTypes.func.isRequired,
    onSave: React.PropTypes.func.isRequired,
  },

  mixins: [PureRenderMixin],

  render () {
    const { settings, intl, onChange, onSave } = this.props;

    const alertStr = <FormattedMessage id='notifications.column_settings.alert' defaultMessage='Desktop notifications' />;
    const showStr  = <FormattedMessage id='notifications.column_settings.show' defaultMessage='Show in column' />;
    const soundStr = <FormattedMessage id='notifications.column_settings.sound' defaultMessage='Play sound' />;

    return (
      <ColumnCollapsable icon='sliders' title={intl.formatMessage(messages.settings)} fullHeight={616} onCollapse={onSave}>
        <div className='column-settings--outer' style={outerStyle}>
          <span className='column-settings--section' style={sectionStyle}><FormattedMessage id='notifications.column_settings.follow' defaultMessage='New followers:' /></span>

          <div style={rowStyle}>
            <SettingToggle settings={settings} settingKey={['alerts', 'follow']} onChange={onChange} label={alertStr} />
            <SettingToggle settings={settings} settingKey={['shows', 'follow']} onChange={onChange} label={showStr} />
            <SettingToggle settings={settings} settingKey={['sounds', 'follow']} onChange={onChange} label={soundStr} />
          </div>

          <span className='column-settings--section' style={sectionStyle}><FormattedMessage id='notifications.column_settings.favourite' defaultMessage='Favourites:' /></span>

          <div style={rowStyle}>
            <SettingToggle settings={settings} settingKey={['alerts', 'favourite']} onChange={onChange} label={alertStr} />
            <SettingToggle settings={settings} settingKey={['shows', 'favourite']} onChange={onChange} label={showStr} />
            <SettingToggle settings={settings} settingKey={['sounds', 'favourite']} onChange={onChange} label={soundStr} />
          </div>

          <span className='column-settings--section' style={sectionStyle}><FormattedMessage id='notifications.column_settings.mention' defaultMessage='Mentions:' /></span>

          <div style={rowStyle}>
            <SettingToggle settings={settings} settingKey={['alerts', 'mention']} onChange={onChange} label={alertStr} />
            <SettingToggle settings={settings} settingKey={['shows', 'mention']} onChange={onChange} label={showStr} />
            <SettingToggle settings={settings} settingKey={['sounds', 'mention']} onChange={onChange} label={soundStr} />
          </div>

          <span className='column-settings--section' style={sectionStyle}><FormattedMessage id='notifications.column_settings.reblog' defaultMessage='Boosts:' /></span>

          <div style={rowStyle}>
            <SettingToggle settings={settings} settingKey={['alerts', 'reblog']} onChange={onChange} label={alertStr} />
            <SettingToggle settings={settings} settingKey={['shows', 'reblog']} onChange={onChange} label={showStr} />
            <SettingToggle settings={settings} settingKey={['sounds', 'reblog']} onChange={onChange} label={soundStr} />
          </div>
        </div>
      </ColumnCollapsable>
    );
  }

});

export default injectIntl(ColumnSettings);
