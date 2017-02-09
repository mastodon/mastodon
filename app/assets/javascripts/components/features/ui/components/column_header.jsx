import PureRenderMixin from 'react-addons-pure-render-mixin';

const ColumnHeader = React.createClass({

  propTypes: {
    icon: React.PropTypes.string,
    type: React.PropTypes.string,
    onClick: React.PropTypes.func
  },

  mixins: [PureRenderMixin],

  handleClick () {
    this.props.onClick();
  },

  render () {
    let icon = '';

    if (this.props.icon) {
      icon = <i className={`fa fa-fw fa-${this.props.icon}`} style={{ display: 'inline-block', marginRight: '5px' }} />;
    }

    return (
      <div className='column-header' onClick={this.handleClick}>
        {icon}
        {this.props.type}
      </div>
    );
  }

});

export default ColumnHeader;
