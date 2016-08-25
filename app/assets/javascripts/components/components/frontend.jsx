import NavBar                  from './nav_bar';
import ColumnsArea             from './columns_area';
import ComposerDrawerContainer from '../containers/composer_drawer_container';

const Frontend = React.createClass({

  render: function() {
    return (
      <div style={{ flex: '0 0 auto', display: 'flex', width: '100%', height: '100%', background: '#1a1c23' }}>
        <NavBar />
        <ComposerDrawerContainer />
        <ColumnsArea />
      </div>
    );
  }
});

export default Frontend;
