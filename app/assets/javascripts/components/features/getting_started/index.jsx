import Column   from '../ui/components/column';
import { Link } from 'react-router';

const GettingStarted = () => {
  return (
    <Column>
      <div className='static-content'>
        <h1>Getting started</h1>
        <p>You can follow people if you know their username and the domain they are on by entering an e-mail-esque address into the form in the bottom of the sidebar.</p>
        <p>If the target user is on the same domain as you, just the username will work. The same rule applies to mentioning people in statuses.</p>
        <p>The developer of this project can be followed as Gargron@mastodon.social</p>
        <p>Also <Link to='/timelines/public' style={{ color: '#2b90d9', textDecoration: 'none' }}>check out the public timeline for a start</Link>!</p>
      </div>
    </Column>
  );
};

export default GettingStarted;
