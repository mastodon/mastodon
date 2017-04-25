import ColumnHeader from './column_header';
import PropTypes from 'prop-types';

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

class Column extends React.PureComponent {

  constructor (props, context) {
    super(props, context);
    this.handleHeaderClick = this.handleHeaderClick.bind(this);
    this.handleWheel = this.handleWheel.bind(this);
  }

  handleHeaderClick () {
    const scrollable = ReactDOM.findDOMNode(this).querySelector('.scrollable');
    if (!scrollable) {
      return;
    }
    this._interruptScrollAnimation = scrollTop(scrollable);
  }

  handleWheel () {
    if (typeof this._interruptScrollAnimation !== 'undefined') {
      this._interruptScrollAnimation();
    }
  }

  render () {
    const { heading, icon, children, active, hideHeadingOnMobile } = this.props;

    let columnHeaderId = null
    let header = '';

    if (heading) {
      columnHeaderId = heading.replace(/ /g, '-')
      header = <ColumnHeader icon={icon} active={active} type={heading} onClick={this.handleHeaderClick} hideOnMobile={hideHeadingOnMobile} columnHeaderId={columnHeaderId}/>;
    }
    return (
      <div role='region' aria-labelledby={columnHeaderId} className='column' onWheel={this.handleWheel}>
        {header}
        {children}
      </div>
    );
  }

}

Column.propTypes = {
  heading: PropTypes.string,
  icon: PropTypes.string,
  children: PropTypes.node,
  active: PropTypes.bool,
  hideHeadingOnMobile: PropTypes.bool
};

export default Column;
