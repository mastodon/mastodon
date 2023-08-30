import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { injectIntl, defineMessages } from 'react-intl';

import classNames from 'classnames';

import api from 'mastodon/api';

const messages = defineMessages({
  legal: { id: 'report.categories.legal', defaultMessage: 'Legal' },
  other: { id: 'report.categories.other', defaultMessage: 'Other' },
  spam: { id: 'report.categories.spam', defaultMessage: 'Spam' },
  violation: { id: 'report.categories.violation', defaultMessage: 'Content violates one or more server rules' },
});

class Category extends PureComponent {

  static propTypes = {
    id: PropTypes.string.isRequired,
    text: PropTypes.string.isRequired,
    selected: PropTypes.bool,
    disabled: PropTypes.bool,
    onSelect: PropTypes.func,
    children: PropTypes.node,
  };

  handleClick = () => {
    const { id, disabled, onSelect } = this.props;

    if (!disabled) {
      onSelect(id);
    }
  };

  render () {
    const { id, text, disabled, selected, children } = this.props;

    return (
      <div tabIndex={0} role='button' className={classNames('report-reason-selector__category', { selected, disabled })} onClick={this.handleClick}>
        {selected && <input type='hidden' name='report[category]' value={id} />}

        <div className='report-reason-selector__category__label'>
          <span className={classNames('poll__input', { active: selected, disabled })} />
          {text}
        </div>

        {(selected && children) && (
          <div className='report-reason-selector__category__rules'>
            {children}
          </div>
        )}
      </div>
    );
  }

}

class Rule extends PureComponent {

  static propTypes = {
    id: PropTypes.string.isRequired,
    text: PropTypes.string.isRequired,
    selected: PropTypes.bool,
    disabled: PropTypes.bool,
    onToggle: PropTypes.func,
  };

  handleClick = () => {
    const { id, disabled, onToggle } = this.props;

    if (!disabled) {
      onToggle(id);
    }
  };

  render () {
    const { id, text, disabled, selected } = this.props;

    return (
      <div tabIndex={0} role='button' className={classNames('report-reason-selector__rule', { selected, disabled })} onClick={this.handleClick}>
        <span className={classNames('poll__input', { checkbox: true, active: selected, disabled })} />
        {selected && <input type='hidden' name='report[rule_ids][]' value={id} />}
        {text}
      </div>
    );
  }

}

class ReportReasonSelector extends PureComponent {

  static propTypes = {
    id: PropTypes.string.isRequired,
    category: PropTypes.string.isRequired,
    rule_ids: PropTypes.arrayOf(PropTypes.string),
    disabled: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  state = {
    category: this.props.category,
    rule_ids: this.props.rule_ids || [],
    rules: [],
  };

  componentDidMount() {
    api().get('/api/v1/instance').then(res => {
      this.setState({
        rules: res.data.rules,
      });
    }).catch(err => {
      console.error(err);
    });
  }

  _save = () => {
    const { id, disabled } = this.props;
    const { category, rule_ids } = this.state;

    if (disabled) {
      return;
    }

    api().put(`/api/v1/admin/reports/${id}`, {
      category,
      rule_ids,
    }).catch(err => {
      console.error(err);
    });
  };

  handleSelect = id => {
    this.setState({ category: id }, () => this._save());
  };

  handleToggle = id => {
    const { rule_ids } = this.state;

    if (rule_ids.includes(id)) {
      this.setState({ rule_ids: rule_ids.filter(x => x !== id ) }, () => this._save());
    } else {
      this.setState({ rule_ids: [...rule_ids, id] }, () => this._save());
    }
  };

  render () {
    const { disabled, intl } = this.props;
    const { rules, category, rule_ids } = this.state;

    return (
      <div className='report-reason-selector'>
        <Category id='other' text={intl.formatMessage(messages.other)} selected={category === 'other'} onSelect={this.handleSelect} disabled={disabled} />
        <Category id='legal' text={intl.formatMessage(messages.legal)} selected={category === 'legal'} onSelect={this.handleSelect} disabled={disabled} />
        <Category id='spam' text={intl.formatMessage(messages.spam)} selected={category === 'spam'} onSelect={this.handleSelect} disabled={disabled} />
        <Category id='violation' text={intl.formatMessage(messages.violation)} selected={category === 'violation'} onSelect={this.handleSelect} disabled={disabled}>
          {rules.map(rule => <Rule key={rule.id} id={rule.id} text={rule.text} selected={rule_ids.includes(rule.id)} onToggle={this.handleToggle} disabled={disabled} />)}
        </Category>
      </div>
    );
  }

}

export default injectIntl(ReportReasonSelector);
