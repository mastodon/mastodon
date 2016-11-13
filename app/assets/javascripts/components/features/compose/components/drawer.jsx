import PureRenderMixin from 'react-addons-pure-render-mixin';

const style = {
  boxSizing: 'border-box',
  background: '#454b5e',
  padding: '0',
  display: 'flex',
  flexDirection: 'column',
  overflowY: 'auto'
};

const Drawer = React.createClass({

  mixins: [PureRenderMixin],

  render () {
    return (
      <div className='drawer' style={style}>
        {this.props.children}
      </div>
    );
  }

});

export default Drawer;
