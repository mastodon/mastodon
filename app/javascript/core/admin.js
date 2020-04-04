//  This file will be loaded on admin pages, regardless of theme.

import { delegate } from '@rails/ujs';
import ready from '../mastodon/ready';

const batchCheckboxClassName = '.batch-checkbox input[type="checkbox"]';

delegate(document, '#batch_checkbox_all', 'change', ({ target }) => {
  [].forEach.call(document.querySelectorAll(batchCheckboxClassName), (content) => {
    content.checked = target.checked;
  });
});

delegate(document, batchCheckboxClassName, 'change', () => {
  const checkAllElement = document.querySelector('#batch_checkbox_all');

  if (checkAllElement) {
    checkAllElement.checked = [].every.call(document.querySelectorAll(batchCheckboxClassName), (content) => content.checked);
    checkAllElement.indeterminate = !checkAllElement.checked && [].some.call(document.querySelectorAll(batchCheckboxClassName), (content) => content.checked);
  }
});

delegate(document, '.media-spoiler-show-button', 'click', () => {
  [].forEach.call(document.querySelectorAll('button.media-spoiler'), (element) => {
    element.click();
  });
});

delegate(document, '.media-spoiler-hide-button', 'click', () => {
  [].forEach.call(document.querySelectorAll('.spoiler-button.spoiler-button--visible button'), (element) => {
    element.click();
  });
});

delegate(document, '.filter-subset--with-select select', 'change', ({ target }) => {
  target.form.submit();
});

const onDomainBlockSeverityChange = (target) => {
  const rejectMediaDiv   = document.querySelector('.input.with_label.domain_block_reject_media');
  const rejectReportsDiv = document.querySelector('.input.with_label.domain_block_reject_reports');

  if (rejectMediaDiv) {
    rejectMediaDiv.style.display = (target.value === 'suspend') ? 'none' : 'block';
  }

  if (rejectReportsDiv) {
    rejectReportsDiv.style.display = (target.value === 'suspend') ? 'none' : 'block';
  }
};

delegate(document, '#domain_block_severity', 'change', ({ target }) => onDomainBlockSeverityChange(target));

const onEnableBootstrapTimelineAccountsChange = (target) => {
  const bootstrapTimelineAccountsField = document.querySelector('#form_admin_settings_bootstrap_timeline_accounts');

  if (bootstrapTimelineAccountsField) {
    bootstrapTimelineAccountsField.disabled = !target.checked;
    if (target.checked) {
      bootstrapTimelineAccountsField.parentElement.classList.remove('disabled');
    } else {
      bootstrapTimelineAccountsField.parentElement.classList.add('disabled');
    }
  }
};

delegate(document, '#form_admin_settings_enable_bootstrap_timeline_accounts', 'change', ({ target }) => onEnableBootstrapTimelineAccountsChange(target));

ready(() => {
  const domainBlockSeverityInput = document.getElementById('domain_block_severity');
  if (domainBlockSeverityInput) onDomainBlockSeverityChange(domainBlockSeverityInput);

  const enableBootstrapTimelineAccounts = document.getElementById('form_admin_settings_enable_bootstrap_timeline_accounts');
  if (enableBootstrapTimelineAccounts) onEnableBootstrapTimelineAccountsChange(enableBootstrapTimelineAccounts);
});
