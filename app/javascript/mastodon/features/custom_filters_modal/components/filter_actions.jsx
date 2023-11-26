import PropTypes from 'prop-types';
import * as React from 'react';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import Option from 'mastodon/components/option';
import { FilterActionTypes } from 'mastodon/utils/filters';

const messages = defineMessages({
  title:            { id: 'custom_filters_modal.filter_actions.title',            defaultMessage: 'Filter action' },
  subtitle:         { id: 'custom_filters_modal.filter_actions.subtitle',         defaultMessage: 'Chose which action to perform when a post matches the filter' },
  warn:             { id: 'custom_filters_modal.filter_actions.warn',             defaultMessage: 'Hide with a warning' },
  warn_description: { id: 'custom_filters_modal.filter_actions.warn_description', defaultMessage: `Hide the filtered content behind a warning mentioning the filter's title` },
  hide:             { id: 'custom_filters_modal.filter_actions.hide',             defaultMessage: 'Hide completely' },
  hide_description: { id: 'custom_filters_modal.filter_actions.hide_description', defaultMessage: 'Completely hide the filtered content, behaving as if it did not exist' },
});

class FilterActions extends React.PureComponent {
  static propTypes = {
    intl: PropTypes.object.isRequired,
    filterAction: PropTypes.oneOf(FilterActionTypes).isRequired,
    onChange: PropTypes.func.isRequired,
  };

  handleFilterActionToggle = (value, checked) => {
    const { onChange } = this.props;

    if (checked) {
      onChange(value);
    }
  };

  render() {
    const { intl, filterAction } = this.props;

    return (
      <label>
        <p><FormattedMessage {...messages.title} /></p>
        <span><FormattedMessage {...messages.subtitle} /></span>
        <div>
          {Object.values(FilterActionTypes).map( (item, index) => (
            <Option
              key={index}
              name='filter-aciton'
              value={item}
              checked={filterAction === item}
              onToggle={this.handleFilterActionToggle}
              label={intl.formatMessage(messages[item])}
              description={intl.formatMessage(messages[`${item}_description`])}
            />
          ))}
        </div>
      </label>
    );
  }
}

export default injectIntl(FilterActions);
