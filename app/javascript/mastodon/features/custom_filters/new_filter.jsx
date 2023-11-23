import PropTypes from 'prop-types';
import * as React from 'react';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import { Button } from 'mastodon/components/button';
import { FilterActionTypes } from 'mastodon/utils/filters';

import FilterActions from './components/filter_actions';
import FilterContexts from './components/filter_contexts';

const messages = defineMessages({
  title:  { id: 'custom_filters_modal.new_filter.title',  defaultMessage: 'Create new filter: {title}' },
  create: { id: 'custom_filters_modal.new_filter.create', defaultMessage: 'Create' },
});

class NewFilter extends React.PureComponent {
  static propTypes = {
    onSubmit: PropTypes.func.isRequired,
    title: PropTypes.string,
  };

  state = {
    filterContext: [],
    filterAction: FilterActionTypes.Warn,
  };

  handleContextsChange = (filterContext) => {
    this.setState({
      'filterContext': filterContext,
    });
  };

  handleActionChange = (filterAction) => {
    this.setState({
      'filterAction': filterAction,
    });
  };

  handleSubmit = () => {
    const { title } = this.props;
    const { filterContext, filterAction } = this.state;

    this.props.onSubmit(title, filterContext, filterAction);
  };

  render() {
    const { title } = this.props;
    const { filterAction, filterContext } = this.state;

    return (
      <>
        <h3 className='report-dialog-modal__title'>
          <FormattedMessage {...messages.title} values={{title: title}} />
        </h3>
        <FilterContexts filterContext={filterContext} onChange={this.handleContextsChange} />
        <FilterActions filterAction={filterAction} onChange={this.handleActionChange} />

        <div className='report-dialog-modal__actions'>
          <Button disabled={filterContext.length < 1} onClick={this.handleSubmit}><FormattedMessage {...messages.create} /></Button>
        </div>
      </>
    );
  }
}

export default injectIntl(NewFilter);
