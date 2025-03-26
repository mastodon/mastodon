import React from 'react';

interface Props {
  text: string;
}

const ColumnSubheading: React.FC<Props> = ({ text }) => {
  return <div className='column-subheading'>{text}</div>;
};

export default ColumnSubheading;
