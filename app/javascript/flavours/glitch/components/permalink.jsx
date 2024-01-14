import PropTypes from 'prop-types';
import { useCallback } from 'react';

import { useAppHistory } from './router';

const Permalink = ({ className, href, to, children, onInterceptClick, ...props }) => {
  const history = useAppHistory();

  const handleClick = useCallback((e) => {
    if (e.button === 0 && !(e.ctrlKey || e.metaKey)) {
      if (onInterceptClick && onInterceptClick()) {
        e.preventDefault();
        return;
      }

      if (history) {
        e.preventDefault();
        history.push(to);
      }
    }
  }, [onInterceptClick, history, to]);

  return (
    <a target='_blank' href={href} onClick={handleClick} className={`permalink${className ? ' ' + className : ''}`} {...props}>
      {children}
    </a>
  );
};

Permalink.propTypes = {
  className: PropTypes.string,
  href: PropTypes.string.isRequired,
  to: PropTypes.string.isRequired,
  children: PropTypes.node,
  onInterceptClick: PropTypes.func,
};

export default Permalink;
