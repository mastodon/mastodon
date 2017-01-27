import PureRenderMixin from 'react-addons-pure-render-mixin';

const style = {
  display: 'flex',
  flex: '1 1 auto',
  overflowX: 'auto'
};

const ColumnsArea = React.createClass({

  propTypes: {
    children: React.PropTypes.node
  },

  mixins: [PureRenderMixin],

  render () {
    return (
      <div className='columns-area' style={style}>
        {this.props.children}
      </div>
    );
  }

});

export default ColumnsArea;
