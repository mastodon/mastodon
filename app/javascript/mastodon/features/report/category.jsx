import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import { List as ImmutableList } from 'immutable';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import { Button } from 'mastodon/components/button';

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
  status: { id: 'report.category.title_status', defaultMessage: 'post' },
  account: { id: 'report.category.title_account', defaultMessage: 'profile' },
});

const mapStateToProps = state => ({
  rules: state.getIn(['server', 'server', 'rules'], ImmutableList()),
});

class Category extends PureComponent {

  static propTypes = {
    onNextStep: PropTypes.func.isRequired,
    rules: ImmutablePropTypes.list,
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

    const options = rules.size > 0 ? [
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

    return (
      <>
        <h3 className='report-dialog-modal__title'><FormattedMessage id='report.category.title' defaultMessage="Tell us what's going on with this {type}" values={{ type: intl.formatMessage(messages[startedFrom]) }} /></h3>
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
