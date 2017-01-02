import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Toggle from 'react-toggle';
import { Motion, spring } from 'react-motion';
import { FormattedMessage } from 'react-intl';

const outerStyle = {
  background: '#373b4a',
  padding: '15px'
};

const iconStyle = {
  fontSize: '16px',
  padding: '15px',
  position: 'absolute',
  right: '0',
  top: '-48px',
  cursor: 'pointer'
};

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
    onChange: React.PropTypes.func.isRequired
  },

  getInitialState () {
    return {
      collapsed: true
    };
  },

  mixins: [PureRenderMixin],

  handleToggleCollapsed () {
    this.setState({ collapsed: !this.state.collapsed });
  },

  handleChange (key, e) {
    this.props.onChange(key, e.target.checked);
  },

  render () {
    const { settings }  = this.props;
    const { collapsed } = this.state;

    const alertStr = <FormattedMessage id='notifications.column_settings.alert' defaultMessage='Desktop notifications' />;
    const showStr  = <FormattedMessage id='notifications.column_settings.show' defaultMessage='Show in column' />;

    return (
      <div style={{ position: 'relative' }}>
        <div style={{...iconStyle, color: collapsed ? '#9baec8' : '#fff', background: collapsed ? '#2f3441' : '#373b4a' }} onClick={this.handleToggleCollapsed}><i className='fa fa-sliders' /></div>

        <Motion defaultStyle={{ opacity: 0, height: 0 }} style={{ opacity: spring(collapsed ? 0 : 100), height: spring(collapsed ? 0 : 458) }}>
          {({ opacity, height }) =>
            <div style={{ overflow: 'hidden', height: `${height}px`, opacity: opacity / 100 }}>
              <div style={outerStyle}>
                <span style={sectionStyle}><FormattedMessage id='notifications.column_settings.follow' defaultMessage='New followers:' /></span>

                <div style={rowStyle}>
                  <label style={labelStyle}>
                    <Toggle checked={settings.getIn(['alerts', 'follow'])} onChange={this.handleChange.bind(this, ['alerts', 'follow'])} />
                    <span style={labelSpanStyle}>{alertStr}</span>
                  </label>

                  <label style={labelStyle}>
                    <Toggle checked={settings.getIn(['shows', 'follow'])} onChange={this.handleChange.bind(this, ['shows', 'follow'])} />
                    <span style={labelSpanStyle}>{showStr}</span>
                  </label>
                </div>

                <span style={sectionStyle}><FormattedMessage id='notifications.column_settings.favourite' defaultMessage='Favourites:' /></span>

                <div style={rowStyle}>
                  <label style={labelStyle}>
                    <Toggle checked={settings.getIn(['alerts', 'favourite'])} onChange={this.handleChange.bind(this, ['alerts', 'favourite'])} />
                    <span style={labelSpanStyle}>{alertStr}</span>
                  </label>

                  <label style={labelStyle}>
                    <Toggle checked={settings.getIn(['shows', 'favourite'])} onChange={this.handleChange.bind(this, ['shows', 'favourite'])} />
                    <span style={labelSpanStyle}>{showStr}</span>
                  </label>
                </div>

                <span style={sectionStyle}><FormattedMessage id='notifications.column_settings.mention' defaultMessage='Mentions:' /></span>

                <div style={rowStyle}>
                  <label style={labelStyle}>
                    <Toggle checked={settings.getIn(['alerts', 'mention'])} onChange={this.handleChange.bind(this, ['alerts', 'mention'])} />
                    <span style={labelSpanStyle}>{alertStr}</span>
                  </label>

                  <label style={labelStyle}>
                    <Toggle checked={settings.getIn(['shows', 'mention'])} onChange={this.handleChange.bind(this, ['shows', 'mention'])} />
                    <span style={labelSpanStyle}>{showStr}</span>
                  </label>
                </div>

                <span style={sectionStyle}><FormattedMessage id='notifications.column_settings.reblog' defaultMessage='Boosts:' /></span>

                <div style={rowStyle}>
                  <label style={labelStyle}>
                    <Toggle checked={settings.getIn(['alerts', 'reblog'])} onChange={this.handleChange.bind(this, ['alerts', 'reblog'])} />
                    <span style={labelSpanStyle}>{alertStr}</span>
                  </label>

                  <label style={labelStyle}>
                    <Toggle checked={settings.getIn(['shows', 'reblog'])} onChange={this.handleChange.bind(this, ['shows', 'reblog'])} />
                    <span style={labelSpanStyle}>{showStr}</span>
                  </label>
                </div>
              </div>
            </div>
          }
        </Motion>
      </div>
    );
  }

});

export default ColumnSettings;
