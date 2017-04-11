import ColumnHeader from './column_header';
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

const Column = React.createClass({

  propTypes: {
    heading: React.PropTypes.string,
    icon: React.PropTypes.string,
    children: React.PropTypes.node,
    active: React.PropTypes.bool
  },

  mixins: [PureRenderMixin],

  handleHeaderClick () {
    const scrollable = ReactDOM.findDOMNode(this).querySelector('.scrollable');
    if (!scrollable) {
      return;
    }
    this._interruptScrollAnimation = scrollTop(scrollable);
  },

  handleWheel () {
    if (typeof this._interruptScrollAnimation !== 'undefined') {
      this._interruptScrollAnimation();
    }
  },

  render () {
    const { heading, icon, children, active } = this.props;

    let header = '';

    if (heading) {
      header = <ColumnHeader icon={icon} active={active} type={heading} onClick={this.handleHeaderClick} />;
    }

    return (
      <div className='column' onWheel={this.handleWheel}>
        {header}
        {children}
      </div>
    );
  }

});

export default Column;
