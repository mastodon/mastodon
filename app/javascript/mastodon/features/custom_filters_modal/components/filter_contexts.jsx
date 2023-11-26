import PropTypes from 'prop-types';
import * as React from 'react';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { FilterContextServerSideTypes } from 'mastodon/utils/filters';

const messages = defineMessages({
  title:         { id: 'custom_filters_modal.filter_contexts.title',         defaultMessage: 'Filter contexts' },
  subtitle:      { id: 'custom_filters_modal.filter_contexts.subtitle',      defaultMessage: 'One or multiple contexts where the filter should apply' },
  home:          { id: 'custom_filters_modal.filter_contexts.home',          defaultMessage: 'Home' },
  lists:         { id: 'custom_filters_modal.filter_contexts.lists',         defaultMessage: 'Lists' },
  notifications: { id: 'custom_filters_modal.filter_contexts.notifications', defaultMessage: 'Notifications' },
  public:        { id: 'custom_filters_modal.filter_contexts.public',        defaultMessage: 'Public timelines' },
  thread:        { id: 'custom_filters_modal.filter_contexts.thread',        defaultMessage: 'Conversations' },
  account:       { id: 'custom_filters_modal.filter_contexts.account',       defaultMessage: 'Profiles' },
});

class FilterContexts extends React.PureComponent {
  static propTypes = {
    intl: PropTypes.object.isRequired,
    filterContext: PropTypes.arrayOf(Object.values(FilterContextServerSideTypes)).isRequired,
    onChange: PropTypes.func.isRequired,
  };

  handleChange = (event) => {
    var filterContext = [...this.props.filterContext];
    let { onChange } = this.props;

    if (event.target.checked) {
      filterContext.push(event.target.name);
    } else {
      filterContext = filterContext.filter((item) => { return item !== event.target.name; });
    }

    onChange(filterContext);
  };

  render() {
    const { filterContext } = this.props;

    return (
      <label >
        <p><FormattedMessage {...messages.title} /></p>
        <span><FormattedMessage {...messages.subtitle} /></span>
        <ul>
          {
            Object.values(FilterContextServerSideTypes).map( (context, index) => (
              <li key={index}>
                <label className={classNames('icon-button', filterContext.includes(context))}>
                  <input
                    name={context}
                    type='checkbox'
                    checked={filterContext.includes(context)}
                    onChange={this.handleChange}
                  />

                  <FormattedMessage
                    {...messages[context]}
                  />
                </label>
              </li>
            ))
          }
        </ul>
      </label>
    );
  }
}

export default injectIntl(FilterContexts);
