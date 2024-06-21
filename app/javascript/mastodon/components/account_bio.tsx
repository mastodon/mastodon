import { useLinks } from 'mastodon/../hooks/useLinks';

export const AccountBio: React.FC<{
  note: string;
  className: string;
}> = ({ note, className }) => {
  const handleClick = useLinks();

  if (note.length === 0 || note === '<p></p>') {
    return null;
  }

  return (
    <div
      className={`${className} translate`}
      dangerouslySetInnerHTML={{ __html: note }}
      onClickCapture={handleClick}
    />
  );
};
