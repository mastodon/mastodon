interface Props {
  size: number;
  strokeWidth: number;
}

export const CircularProgress: React.FC<Props> = ({ size, strokeWidth }) => {
  const viewBox = `0 0 ${size} ${size}`;
  const radius = (size - strokeWidth) / 2;

  return (
    <svg
      width={size}
      height={size}
      viewBox={viewBox}
      className='circular-progress'
      role='progressbar'
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
