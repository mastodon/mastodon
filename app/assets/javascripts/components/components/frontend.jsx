import NavBar      from './nav_bar';
import ColumnsArea from './columns_area';

const Frontend = React.createClass({

  render: function() {
    return (
      <div style={{ flex: '0 0 auto', display: 'flex', width: '100%', height: '100%', background: '#1a1c23' }}>
        <NavBar />
        <ColumnsArea />
      </div>
    );
  }
});

export default Frontend;
