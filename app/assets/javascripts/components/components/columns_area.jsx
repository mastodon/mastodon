import Column          from './column';
import PureRenderMixin from 'react-addons-pure-render-mixin';

const ColumnsArea = React.createClass({

  mixins: [PureRenderMixin],

  render () {
    return (
      <div style={{ display: 'flex', flexDirection: 'row', flex: '1' }}>
        <Column icon='home' type='home' />
        <Column icon='at' type='mentions' />
      </div>
    );
  }

});

export default ColumnsArea;
