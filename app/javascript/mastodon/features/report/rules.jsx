import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import { Button } from 'mastodon/components/button';

import Option from './components/option';

const mapStateToProps = state => ({
  rules: state.getIn(['server', 'server', 'rules']),
  locale: state.getIn(['meta', 'locale']),
});

class Rules extends PureComponent {

  static propTypes = {
    onNextStep: PropTypes.func.isRequired,
    rules: ImmutablePropTypes.list,
    locale: PropTypes.string,
    selectedRuleIds: ImmutablePropTypes.set.isRequired,
    onToggle: PropTypes.func.isRequired,
  };

  handleNextClick = () => {
    const { onNextStep } = this.props;
    onNextStep('statuses');
  };

  handleRulesToggle = (value, checked) => {
    const { onToggle } = this.props;
    onToggle(value, checked);
  };

  render () {
    const { rules, locale, selectedRuleIds } = this.props;

    return (
      <>
        <h3 className='report-dialog-modal__title'><FormattedMessage id='report.rules.title' defaultMessage='Which rules are being violated?' /></h3>
        <p className='report-dialog-modal__lead'><FormattedMessage id='report.rules.subtitle' defaultMessage='Select all that apply' /></p>

        <div>
          {rules.map(item => (
            <Option
              key={item.get('id')}
              name='rule_ids'
              value={item.get('id')}
              checked={selectedRuleIds.includes(item.get('id'))}
              onToggle={this.handleRulesToggle}
              label={item.getIn(['translations', locale, 'text']) || item.getIn(['translations', locale.split('-')[0], 'text']) || item.get('text')}
              multiple
            />
          ))}
        </div>

        <div className='flex-spacer' />

        <div className='report-dialog-modal__actions'>
          <Button onClick={this.handleNextClick} disabled={selectedRuleIds.size < 1}><FormattedMessage id='report.next' defaultMessage='Next' /></Button>
        </div>
      </>
    );
  }

}

export default connect(mapStateToProps)(Rules);
