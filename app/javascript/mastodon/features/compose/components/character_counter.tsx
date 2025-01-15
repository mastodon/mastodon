import { length } from 'stringz';

export const CharacterCounter: React.FC<{
  text: string;
  max: number;
}> = ({ text, max }) => {
  const diff = max - length(text);

  if (diff < 0) {
    return (
      <span className='character-counter character-counter--over'>{diff}</span>
    );
  }

  return <span className='character-counter'>{diff}</span>;
};
