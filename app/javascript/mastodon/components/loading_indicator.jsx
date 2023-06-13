import { CircularProgress } from "./circle_progress";

const LoadingIndicator = () => (
  <div className='loading-indicator'>
    <CircularProgress size={50} strokeWidth={6} />
  </div>
);

export default LoadingIndicator;
