import classNames from 'classnames';

interface Props {
  message: React.ReactNode;
  label: React.ReactNode;
  url: string;
  className?: string;
}

export const TimelineHint: React.FC<Props> = ({
  className,
  message,
  label,
  url,
}) => (
  <div className={classNames('timeline-hint', className)}>
    <p>{message}</p>

    <a href={url} target='_blank' rel='noopener noreferrer'>
      {label}
    </a>
  </div>
);
