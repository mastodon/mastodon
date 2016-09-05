import StatusListContainer from '../containers/status_list_container';
import ColumnHeader        from './column_header';
import PureRenderMixin     from 'react-addons-pure-render-mixin';

const Column = React.createClass({

  propTypes: {
    type: React.PropTypes.string,
    icon: React.PropTypes.string
  },

  mixins: [PureRenderMixin],

  handleHeaderClick () {
    let node = ReactDOM.findDOMNode(this);
    node.querySelector('.scrollable').scrollTo(0, 0);
  },

  render () {
    return (
      <div style={{ width: '380px', flex: '0 0 auto', background: '#282c37', margin: '10px', marginRight: '0', display: 'flex', flexDirection: 'column' }}>
        <ColumnHeader icon={this.props.icon} type={this.props.type} onClick={this.handleHeaderClick} />
        <StatusListContainer type={this.props.type} />
      </div>
    );
  }

});

export default Column;
