import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ColumnCollapsable from '../../../components/column_collapsable';
import SettingToggle from '../../notifications/components/setting_toggle';
import SettingText from './setting_text';

const messages = defineMessages({
  filter_regex: { id: 'home.column_settings.filter_regex', defaultMessage: 'Filter out by regular expressions' },
  settings: { id: 'home.settings', defaultMessage: 'Column settings' }
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
    onChange: React.PropTypes.func.isRequired,
    onSave: React.PropTypes.func.isRequired,
    intl: React.PropTypes.object.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    const { settings, onChange, onSave, intl } = this.props;

    return (
      <ColumnCollapsable icon='sliders' title={intl.formatMessage(messages.settings)} fullHeight={209} onCollapse={onSave}>
        <div className='column-settings--outer' style={outerStyle}>
          <span className='column-settings--section' style={sectionStyle}><FormattedMessage id='home.column_settings.basic' defaultMessage='Basic' /></span>

          <div style={rowStyle}>
            <SettingToggle settings={settings} settingKey={['shows', 'reblog']} onChange={onChange} label={<FormattedMessage id='home.column_settings.show_reblogs' defaultMessage='Show boosts' />} />
          </div>

          <div style={rowStyle}>
            <SettingToggle settings={settings} settingKey={['shows', 'reply']} onChange={onChange} label={<FormattedMessage id='home.column_settings.show_replies' defaultMessage='Show replies' />} />
          </div>

          <span className='column-settings--section' style={sectionStyle}><FormattedMessage id='home.column_settings.advanced' defaultMessage='Advanced' /></span>

          <div style={rowStyle}>
            <SettingText settings={settings} settingKey={['regex', 'body']} onChange={onChange} label={intl.formatMessage(messages.filter_regex)} />
          </div>
        </div>
      </ColumnCollapsable>
    );
  }

});

export default injectIntl(ColumnSettings);
