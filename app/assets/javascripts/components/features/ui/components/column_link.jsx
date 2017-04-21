import { Link } from 'react-router';

const outerStyle = {
  padding: '15px',
  fontSize: '16px',
  textDecoration: 'none'
};

const iconStyle = {
  display: 'inline-block',
  marginRight: '5px'
};

const ColumnLink = ({ icon, text, to, href, method, hideOnMobile }) => {
  if (href) {
    return (
      <a href={href} style={outerStyle} className={`column-link ${hideOnMobile ? 'hidden-on-mobile' : ''}`} data-method={method}>
        <i className={`fa fa-fw fa-${icon}`} style={iconStyle} />
        {text}
      </a>
    );
  } else {
    return (
      <Link to={to} style={outerStyle} className={`column-link ${hideOnMobile ? 'hidden-on-mobile' : ''}`}>
        <i className={`fa fa-fw fa-${icon}`} style={iconStyle} />
        {text}
      </Link>
    );
  }
};

ColumnLink.propTypes = {
  icon: React.PropTypes.string.isRequired,
  text: React.PropTypes.string.isRequired,
  to: React.PropTypes.string,
  href: React.PropTypes.string,
  method: React.PropTypes.string,
  hideOnMobile: React.PropTypes.bool
};

export default ColumnLink;
