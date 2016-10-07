import PureRenderMixin from 'react-addons-pure-render-mixin';

const ColumnsArea = React.createClass({

  mixins: [PureRenderMixin],

  render () {
    return (
      <div style={{ display: 'flex', flexDirection: 'row', flex: '1', justifyContent: 'flex-start', marginRight: '10px', marginBottom: '10px', overflowX: 'auto' }}>
        {this.props.children}
      </div>
    );
  }

});

export default ColumnsArea;
