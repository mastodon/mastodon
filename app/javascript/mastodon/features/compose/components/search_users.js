import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';
import Icon from 'mastodon/components/icon';

const messages = defineMessages({
  placeholder: {
    id: 'lists.extend_list.search_placeholder',
    defaultMessage: 'Search users: @username@domain',
  },
});

export default
@injectIntl
class SearchUsers extends React.PureComponent {
  static contextTypes = {
    router: PropTypes.object.isRequired,
  };

  static propTypes = {
    value: PropTypes.string.isRequired,
    submitted: PropTypes.bool,
    onChange: PropTypes.func.isRequired,
    onSubmit: PropTypes.func.isRequired,
    onClear: PropTypes.func.isRequired,
    onShow: PropTypes.func.isRequired,
    openInRoute: PropTypes.bool,
    intl: PropTypes.object.isRequired,
    singleColumn: PropTypes.bool,
  };

  state = {
    expanded: false,
  };

  setRef = (c) => {
    this.searchForm = c;
  };

  handleChange = (e) => {
    this.props.onChange(e.target.value);
  };

  handleClear = (e) => {
    e.preventDefault();

    if (this.props.value.length > 0 || this.props.submitted) {
      this.props.onClear();
    }
  };

  handleKeyUp = (e) => {
    if (e.key === 'Enter') {
      e.preventDefault();

      this.props.onSubmit();

      if (this.props.openInRoute) {
        this.context.router.history.push('/search');
      }
    } else if (e.key === 'Escape') {
      document.querySelector('.ui').parentElement.focus();
    }
  };

  handleFocus = () => {
    this.setState({ expanded: true });
    this.props.onShow();

    if (this.searchForm && !this.props.singleColumn) {
      const { left, right } = this.searchForm.getBoundingClientRect();
      if (
        left < 0 ||
        right > (window.innerWidth || document.documentElement.clientWidth)
      ) {
        this.searchForm.scrollIntoView();
      }
    }
  };

  handleBlur = () => {
    this.setState({ expanded: false });
  };

  componentDidMount() {
    if (this.props.searchTerm !== '') {
      this.props.onClear();
    }
  }

  render() {
    const { intl, value, submitted } = this.props;
    const hasValue = value.length > 0 || submitted;

    return (
      <div className="list-creator search">
        <label>
          <span style={{ display: 'none' }}>
            {intl.formatMessage(messages.placeholder)}
          </span>
          <input
            ref={this.setRef}
            className="search__input"
            type="text"
            placeholder={intl.formatMessage(messages.placeholder)}
            value={value}
            onChange={this.handleChange}
            onKeyUp={this.handleKeyUp}
            onFocus={this.handleFocus}
            onBlur={this.handleBlur}
          />
        </label>

        <div
          role="button"
          tabIndex="0"
          className="search__icon"
          onClick={this.handleClear}
        >
          <Icon id="search" className={hasValue ? '' : 'active'} />
          <Icon
            id="times-circle"
            className={hasValue ? 'active' : ''}
            aria-label={intl.formatMessage(messages.placeholder)}
          />
        </div>
      </div>
    );
  }
}
