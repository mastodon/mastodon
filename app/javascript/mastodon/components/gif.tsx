import { useHovering } from '@/hooks/useHovering';
import { autoPlayGif } from 'mastodon/initial_state';

export const GIF: React.FC<{
  src: string;
  staticSrc: string;
  className: string;
  animate?: boolean;
}> = ({ src, staticSrc, className, animate = autoPlayGif }) => {
  const { hovering, handleMouseEnter, handleMouseLeave } = useHovering(animate);

  return (
    <img
      className={className}
      src={hovering || animate ? src : staticSrc}
      alt=''
      role='presentation'
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
    />
  );
};
