import PropTypes from 'prop-types'

class ColumnHeader extends React.PureComponent {

  constructor (props, context) {
    super(props, context);
    this.handleClick = this.handleClick.bind(this);
  }

  handleClick () {
    this.props.onClick();
  }

  render () {
    const { type, active, hideOnMobile } = this.props;

    let icon = '';

    if (this.props.icon) {
      icon = <i className={`fa fa-fw fa-${this.props.icon}`} style={{ display: 'inline-block', marginRight: '5px' }} />;
    }

    return (
      <div role='button' tabIndex='0' aria-label={type} className={`column-header ${active ? 'active' : ''} ${hideOnMobile ? 'hidden-on-mobile' : ''}`} onClick={this.handleClick}>
        {icon}
        {type}
      </div>
    );
  }

}

ColumnHeader.propTypes = {
  icon: PropTypes.string,
  type: PropTypes.string,
  active: PropTypes.bool,
  onClick: PropTypes.func,
  hideOnMobile: PropTypes.bool
};

export default ColumnHeader;
