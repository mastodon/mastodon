import { Link } from 'react-router';
import Icon from '../../../components/icon';

const outerStyle = {
  display: 'block',
  padding: '15px',
  fontSize: '16px',
  textDecoration: 'none'
};

const iconStyle = {
  display: 'inline-block',
  marginRight: '5px'
};

const ColumnLink = ({ icon, text, to, href, method }) => {
  if (href) {
    return (
      <a href={href} style={outerStyle} className='column-link' data-method={method}>
        <Icon icon={icon} style={iconStyle} />
        {text}
      </a>
    );
  } else {
    return (
      <Link to={to} style={outerStyle} className='column-link'>
        <Icon icon={icon} style={iconStyle} />
        {text}
      </Link>
    );
  }
};

ColumnLink.propTypes = {
  icon: React.PropTypes.string.isRequired,
  text: React.PropTypes.string.isRequired,
  to: React.PropTypes.string,
  href: React.PropTypes.string
};

export default ColumnLink;
