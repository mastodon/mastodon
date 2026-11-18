import classNames from 'classnames';

interface Props {
  width?: number | string;
  height?: number | string;
}

export const Skeleton: React.FC<
  Props & React.ComponentPropsWithRef<'span'>
> = ({ className, width, height, style, ...props }) => (
  <span
    {...props}
    className={classNames(className, 'skeleton')}
    style={{ ...style, width, height }}
  >
    &zwnj;
  </span>
);
