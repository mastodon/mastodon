/**
 * wrapper of <time> tag that auto-catches invalid date.
 * @param root0
 * @param root0.dateTime
 * @param root0.children
 */
export const Time: React.FC<React.TimeHTMLAttributes<HTMLTimeElement>> = ({
  dateTime,
  children,
  ...props
}) => (
  <time dateTime={tryIsoString(dateTime)} {...props}>
    {children}
  </time>
);

const tryIsoString = (date?: string | Date): string => {
  if (!date) {
    return '';
  }
  try {
    return new Date(date).toISOString();
  } catch {
    return `${date}`;
  }
};
