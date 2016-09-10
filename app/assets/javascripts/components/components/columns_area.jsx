import PureRenderMixin from 'react-addons-pure-render-mixin';

const ColumnsArea = React.createClass({

  mixins: [PureRenderMixin],

  render () {
    return (
      <div style={{ display: 'flex', flexDirection: 'row', flex: '1' }}>
        {this.props.children}
      </div>
    );
  }

});

export default ColumnsArea;
