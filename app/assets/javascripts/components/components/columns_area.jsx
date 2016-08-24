import Column from './column';

const ColumnsArea = React.createClass({

  render: function() {
    return (
      <div style={{ display: 'flex', flexDirection: 'row', flex: '1' }}>
        <Column type='home' />
        <Column type='mentions' />
      </div>
    );
  }
});

export default ColumnsArea;
