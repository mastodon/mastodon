import { useCallback } from 'react';

import { useAppHistory } from './router';

interface Props extends React.AnchorHTMLAttributes<HTMLAnchorElement> {
  to: string;
}

export const Permalink: React.FC<Props> = ({
  className,
  href,
  to,
  children,
  ...props
}) => {
  const history = useAppHistory();

  const handleClick = useCallback<React.MouseEventHandler<HTMLAnchorElement>>(
    (e) => {
      // eslint-disable-next-line @typescript-eslint/no-unnecessary-condition -- history can actually be undefined as the component can be mounted outside a router context
      if (e.button === 0 && !(e.ctrlKey || e.metaKey) && history) {
        e.preventDefault();
        history.push(to);
      }
    },
    [history, to],
  );

  return (
    <a
      target='_blank'
      rel='noreferrer'
      href={href}
      onClick={handleClick}
      className={`permalink${className ? ' ' + className : ''}`}
      {...props}
    >
      {children}
    </a>
  );
};
