import PureRenderMixin from 'react-addons-pure-render-mixin';

const ColumnHeader = React.createClass({

  propTypes: {
    icon: React.PropTypes.string,
    type: React.PropTypes.string,
    active: React.PropTypes.bool,
    onClick: React.PropTypes.func
  },

  mixins: [PureRenderMixin],

  handleClick () {
    this.props.onClick();
  },

  render () {
    const { type, active } = this.props;

    let icon = '';

    if (this.props.icon) {
      icon = <i className={`fa fa-fw fa-${this.props.icon}`} style={{ display: 'inline-block', marginRight: '5px' }} />;
    }

    return (
      <div role='button' tabIndex='0' aria-label={type} className={`column-header ${active ? 'active' : ''}`} onClick={this.handleClick}>
        {icon}
        {type}
      </div>
    );
  }

});

export default ColumnHeader;
