import ColumnHeader    from './column_header';
import PureRenderMixin from 'react-addons-pure-render-mixin';

const easingOutQuint = (x, t, b, c, d) => c*((t=t/d-1)*t*t*t*t + 1) + b;

const scrollTop = (node) => {
  const startTime = Date.now();
  const offset    = node.scrollTop;
  const targetY   = -offset;
  const duration  = 1000;
  let interrupt   = false;

  const step = () => {
    const elapsed    = Date.now() - startTime;
    const percentage = elapsed / duration;

    if (percentage > 1 || interrupt) {
      return;
    }

    node.scrollTop = easingOutQuint(0, elapsed, offset, targetY, duration);
    requestAnimationFrame(step);
  };

  step();

  return () => {
    interrupt = true;
  };
};

const style = {
  height: '100%',
  boxSizing: 'border-box',
  flex: '0 0 auto',
  background: '#282c37',
  display: 'flex',
  flexDirection: 'column'
};

const Column = React.createClass({

  propTypes: {
    heading: React.PropTypes.string,
    icon: React.PropTypes.string
  },

  mixins: [PureRenderMixin],

  handleHeaderClick () {
    let node = ReactDOM.findDOMNode(this);
    this._interruptScrollAnimation = scrollTop(node.querySelector('.scrollable'));
  },

  handleWheel () {
    if (typeof this._interruptScrollAnimation !== 'undefined') {
      this._interruptScrollAnimation();
    }
  },

  render () {
    let header = '';

    if (this.props.heading) {
      header = <ColumnHeader icon={this.props.icon} type={this.props.heading} onClick={this.handleHeaderClick} />;
    }

    return (
      <div className='column' style={style} onWheel={this.handleWheel}>
        {header}
        {this.props.children}
      </div>
    );
  }

});

export default Column;
