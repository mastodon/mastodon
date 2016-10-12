import PureRenderMixin from 'react-addons-pure-render-mixin';

const style = {
  height: '100%',
  flex: '0 0 auto',
  boxSizing: 'border-box',
  background: '#454b5e',
  padding: '0',
  display: 'flex',
  flexDirection: 'column'
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
