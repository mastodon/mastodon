import React from 'react';
import { useHistory } from 'react-router';

interface Props
  extends React.PropsWithChildren<React.HTMLAttributes<HTMLAnchorElement>> {
  className?: string;
  href?: string;
  to: string;
  onInterceptClick?: () => boolean;
}

const Permalink: React.FC<Props> = (inProps) => {
  const { className, href, to, onInterceptClick, children, ...props } = inProps;
  const history = useHistory();

  const linkClickHandler = (e: React.MouseEvent<HTMLAnchorElement>) => {
    if (onInterceptClick && onInterceptClick()) {
      e.preventDefault();
      return;
    }

    if (e.button === 0 && !(e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      history.push(to);
    }
  };

  return (
    <a
      target="_blank"
      href={href}
      onClick={linkClickHandler}
      {...props}
      className={`permalink${className ? ' ' + className : ''}`}
    >
      {children}
    </a>
  );
};

export default Permalink;
