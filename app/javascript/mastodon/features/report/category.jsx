import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { defineMessages, FormattedMessage } from 'react-intl';

import { connect } from 'react-redux';

import { Button } from 'mastodon/components/button';
import { NavigationFocusTarget } from 'mastodon/components/navigation_focus_target';
import { injectIntl } from '@/mastodon/components/intl';

import Option from './components/option';

const messages = defineMessages({
  dislike: { id: 'report.reasons.dislike', defaultMessage: 'I don\'t like it' },
  dislike_description: { id: 'report.reasons.dislike_description', defaultMessage: 'It is not something you want to see' },
  spam: { id: 'report.reasons.spam', defaultMessage: 'It\'s spam' },
  spam_description: { id: 'report.reasons.spam_description', defaultMessage: 'Malicious links, fake engagement, or repetitive replies' },
  legal: { id: 'report.reasons.legal', defaultMessage: 'It\'s illegal' },
  legal_description: { id: 'report.reasons.legal_description', defaultMessage: 'You believe it violates the law of your or the server\'s country' },
  violation: { id: 'report.reasons.violation', defaultMessage: 'It violates server rules' },
  violation_description: { id: 'report.reasons.violation_description', defaultMessage: 'You are aware that it breaks specific rules' },
  other: { id: 'report.reasons.other', defaultMessage: 'It\'s something else' },
  other_description: { id: 'report.reasons.other_description', defaultMessage: 'The issue does not fit into other categories' },
  status: { id: 'report.category.title_status', defaultMessage: "Tell us what's going on with this post" },
  account: { id: 'report.category.title_account', defaultMessage: "Tell us what's going on with this profile" },
  collection: { id: 'report.category.title_collection', defaultMessage: "Tell us what's going on with this collection"}
});

const mapStateToProps = state => ({
  rules: state.getIn(['server', 'server', 'item', 'rules'], []),
});

class Category extends PureComponent {

  static propTypes = {
    onNextStep: PropTypes.func.isRequired,
    rules: PropTypes.arrayOf(PropTypes.object),
    category: PropTypes.string,
    onChangeCategory: PropTypes.func.isRequired,
    startedFrom: PropTypes.oneOf(['status', 'account']),
    intl: PropTypes.object.isRequired,
  };

  handleNextClick = () => {
    const { onNextStep, category } = this.props;

    switch(category) {
    case 'dislike':
      onNextStep('thanks');
      break;
    case 'violation':
      onNextStep('rules');
      break;
    default:
      onNextStep('statuses');
      break;
    }
  };

  handleCategoryToggle = (value, checked) => {
    const { onChangeCategory } = this.props;

    if (checked) {
      onChangeCategory(value);
    }
  };

  render () {
    const { category, startedFrom, rules, intl } = this.props;

    let options = rules.length > 0 ? [
      'dislike',
      'spam',
      'legal',
      'violation',
      'other',
    ] : [
      'dislike',
      'spam',
      'legal',
      'other',
    ];

    if (startedFrom === 'collection') {
      options = options.filter(item => item !== 'dislike');
    }

    return (
      <>
        <NavigationFocusTarget as='h1' className='report-dialog-modal__title'>
          {intl.formatMessage(messages[startedFrom])}
        </NavigationFocusTarget>
        <p className='report-dialog-modal__lead'><FormattedMessage id='report.category.subtitle' defaultMessage='Choose the best match' /></p>

        <div>
          {options.map(item => (
            <Option
              key={item}
              name='category'
              value={item}
              checked={category === item}
              onToggle={this.handleCategoryToggle}
              label={intl.formatMessage(messages[item])}
              description={intl.formatMessage(messages[`${item}_description`])}
            />
          ))}
        </div>

        <div className='flex-spacer' />

        <div className='report-dialog-modal__actions'>
          <Button onClick={this.handleNextClick} disabled={category === null}><FormattedMessage id='report.next' defaultMessage='Next' /></Button>
        </div>
      </>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(Category));
