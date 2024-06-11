interface Props {
  width?: number | string;
  height?: number | string;
}

export const Skeleton: React.FC<Props> = ({ width, height }) => (
  <span className='skeleton' style={{ width, height }}>
    &zwnj;
  </span>
);
