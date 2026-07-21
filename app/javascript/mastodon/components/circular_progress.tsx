import classNames from 'classnames';

interface Props {
  size: number;
  strokeWidth: number;
}

export const CircularProgress: React.FC<
  Props & React.SVGAttributes<SVGElement>
> = ({ size, strokeWidth, className, ...props }) => {
  const viewBox = `0 0 ${size} ${size}`;
  const radius = (size - strokeWidth) / 2;

  return (
    <svg
      width={size}
      height={size}
      viewBox={viewBox}
      className={classNames('circular-progress', className)}
      role='progressbar'
      {...props}
    >
      <circle
        fill='none'
        cx={size / 2}
        cy={size / 2}
        r={radius}
        strokeWidth={`${strokeWidth}px`}
      />
    </svg>
  );
};
