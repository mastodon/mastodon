import ColumnsArea             from './columns_area';
import ComposerDrawerContainer from '../containers/composer_drawer_container';
import PureRenderMixin         from 'react-addons-pure-render-mixin';

const Frontend = React.createClass({

  mixins: [PureRenderMixin],

  render () {
    return (
      <div style={{ flex: '0 0 auto', display: 'flex', width: '100%', height: '100%', background: '#1a1c23' }}>
        <ComposerDrawerContainer />
        <ColumnsArea />
      </div>
    );
  }

});

export default Frontend;
