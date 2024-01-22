import type { IconProp } from './icon';
import { Icon } from './icon';

const formatNumber = (num: number): number | string => (num > 40 ? '40+' : num);

interface Props {
  id: string;
  icon: IconProp;
  count: number;
  issueBadge: boolean;
  className: string;
}
export const IconWithBadge: React.FC<Props> = ({
  id,
  icon,
  count,
  issueBadge,
  className,
}) => (
  <i className='icon-with-badge'>
    <Icon id={id} icon={icon} className={className} />
    {count > 0 && (
      <i className='icon-with-badge__badge'>{formatNumber(count)}</i>
    )}
    {issueBadge && <i className='icon-with-badge__issue-badge' />}
  </i>
);
