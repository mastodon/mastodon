import { useLinks } from 'mastodon/../hooks/useLinks';

export const AccountBio: React.FC<{
  note: string;
  className: string;
}> = ({ note, className }) => {
  const ref = useLinks(note);

  if (note.length === 0 || note === '<p></p>') {
    return null;
  }

  return (
    <div
      ref={ref}
      className={`${className} translate`}
      dangerouslySetInnerHTML={{ __html: note }}
    />
  );
};
