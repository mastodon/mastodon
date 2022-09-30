import React from 'react';
import { defineMessages, injectIntl } from 'react-intl';
import PropTypes from 'prop-types';
import Column from 'mastodon/components/column';
import LinkFooter from 'mastodon/features/ui/components/link_footer';
import { Helmet } from 'react-helmet';
import { title } from 'mastodon/initial_state';

const messages = defineMessages({
  title: { id: 'column.about', defaultMessage: 'About' },
});

export default @injectIntl
class About extends React.PureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { intl } = this.props;

    return (
      <Column>
        <LinkFooter />

        <Helmet>
          <title>{intl.formatMessage(messages.title)} - {title}</title>
        </Helmet>
      </Column>
    );
  }

}
