import PureRenderMixin from 'react-addons-pure-render-mixin';

const Drawer = React.createClass({

  mixins: [PureRenderMixin],

  render () {
    return (
      <div style={{ width: '280px', flex: '0 0 auto', boxSizing: 'border-box', background: '#454b5e', margin: '10px', marginRight: '0', padding: '0', display: 'flex', flexDirection: 'column' }}>
        {this.props.children}
      </div>
    );
  }

});

export default Drawer;
