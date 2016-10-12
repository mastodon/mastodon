import { Link } from 'react-router';

const outerStyle = {
  background: '#373b4a',
  margin: '10px',
  flex: '0 0 auto',
  marginBottom: '0',
  display: 'flex'
};

const tabStyle = {
  display: 'block',
  flex: '1 1 auto',
  padding: '10px',
  color: '#fff',
  textDecoration: 'none',
  fontSize: '12px',
  fontWeight: '500',
  borderBottom: '2px solid #373b4a'
};

const tabActiveStyle = {
  borderBottom: '2px solid #2b90d9',
  color: '#2b90d9'
};

const TabsBar = () => {
  return (
    <div style={outerStyle}>
      <Link style={tabStyle} activeStyle={tabActiveStyle} to='/statuses/new'><i className='fa fa-fw fa-pencil' /> Compose</Link>
      <Link style={tabStyle} activeStyle={tabActiveStyle} to='/statuses/home'><i className='fa fa-fw fa-home' /> Home</Link>
      <Link style={tabStyle} activeStyle={tabActiveStyle} to='/statuses/mentions'><i className='fa fa-fw fa-at' /> Mentions</Link>
      <Link style={tabStyle} activeStyle={tabActiveStyle} to='/statuses/all'><i className='fa fa-fw fa-globe' /> Public</Link>
    </div>
  );
};

export default TabsBar;
