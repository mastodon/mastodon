import ColumnHeader    from './column_header';
import PureRenderMixin from 'react-addons-pure-render-mixin';

const Column = React.createClass({

  propTypes: {
    heading: React.PropTypes.string,
    icon: React.PropTypes.string,
    fluid: React.PropTypes.bool
  },

  mixins: [PureRenderMixin],

  handleHeaderClick () {
    let node = ReactDOM.findDOMNode(this);
    node.querySelector('.scrollable').scrollTo(0, 0);
  },

  render () {
    let header = '';

    if (this.props.heading) {
      header = <ColumnHeader icon={this.props.icon} type={this.props.heading} onClick={this.handleHeaderClick} />;
    }

    const style = { width: '350px', flex: '0 0 auto', background: '#282c37', margin: '10px', marginRight: '0', display: 'flex', flexDirection: 'column' };

    if (this.props.fluid) {
      style.width      = 'auto';
      style.flex       = '1 1 auto';
      style.background = '#21242d';
    }

    return (
      <div style={style}>
        {header}
        {this.props.children}
      </div>
    );
  }

});

export default Column;
