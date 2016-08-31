import StatusListContainer from '../containers/status_list_container';
import ColumnHeader        from './column_header';
import PureRenderMixin     from 'react-addons-pure-render-mixin';

const Column = React.createClass({

  propTypes: {
    type: React.PropTypes.string
  },

  mixins: [PureRenderMixin],

  render () {
    return (
      <div style={{ width: '380px', flex: '0 0 auto', background: '#282c37', margin: '10px', marginRight: '0', display: 'flex', flexDirection: 'column' }}>
        <ColumnHeader type={this.props.type} />
        <StatusListContainer type={this.props.type} />
      </div>
    );
  }

});

export default Column;
