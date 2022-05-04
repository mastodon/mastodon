import PropTypes from 'prop-types';

export const CircularProgress = ({ size, strokeWidth }) => {
  const viewBox = `0 0 ${size} ${size}`;
  const radius  = (size - strokeWidth) / 2;

  return (
    <svg width={size} height={size} viewBox={viewBox} className='circular-progress' role='progressbar'>
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

CircularProgress.propTypes = {
  size: PropTypes.number.isRequired,
  strokeWidth: PropTypes.number.isRequired,
};

const LoadingIndicator = () => (
  <div className='loading-indicator'>
    <CircularProgress size={50} strokeWidth={6} />
  </div>
);

export default LoadingIndicator;
