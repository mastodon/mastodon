import './public-path';
import { delegate } from '@rails/ujs';
import ready from '../mastodon/ready';

const setAnnouncementEndsAttributes = (target) => {
  const valid = target?.value && target?.validity?.valid;
  const element = document.querySelector('input[type="datetime-local"]#announcement_ends_at');
  if (valid) {
    element.classList.remove('optional');
    element.required = true;
    element.min = target.value;
  } else {
    element.classList.add('optional');
    element.removeAttribute('required');
    element.removeAttribute('min');
  }
};

delegate(document, 'input[type="datetime-local"]#announcement_starts_at', 'change', ({ target }) => {
  setAnnouncementEndsAttributes(target);
});

const batchCheckboxClassName = '.batch-checkbox input[type="checkbox"]';

const showSelectAll = () => {
  const selectAllMatchingElement = document.querySelector('.batch-table__select-all');
  selectAllMatchingElement.classList.add('active');
};

const hideSelectAll = () => {
  const selectAllMatchingElement = document.querySelector('.batch-table__select-all');
  const hiddenField = document.querySelector('#select_all_matching');
  const selectedMsg = document.querySelector('.batch-table__select-all .selected');
  const notSelectedMsg = document.querySelector('.batch-table__select-all .not-selected');

  selectAllMatchingElement.classList.remove('active');
  selectedMsg.classList.remove('active');
  notSelectedMsg.classList.add('active');
  hiddenField.value = '0';
};

delegate(document, '#batch_checkbox_all', 'change', ({ target }) => {
  const selectAllMatchingElement = document.querySelector('.batch-table__select-all');

  [].forEach.call(document.querySelectorAll(batchCheckboxClassName), (content) => {
    content.checked = target.checked;
  });

  if (selectAllMatchingElement) {
    if (target.checked) {
      showSelectAll();
    } else {
      hideSelectAll();
    }
  }
});

delegate(document, '.batch-table__select-all button', 'click', () => {
  const hiddenField = document.querySelector('#select_all_matching');
  const active = hiddenField.value === '1';
  const selectedMsg = document.querySelector('.batch-table__select-all .selected');
  const notSelectedMsg = document.querySelector('.batch-table__select-all .not-selected');

  if (active) {
    hiddenField.value = '0';
    selectedMsg.classList.remove('active');
    notSelectedMsg.classList.add('active');
  } else {
    hiddenField.value = '1';
    notSelectedMsg.classList.remove('active');
    selectedMsg.classList.add('active');
  }
});

delegate(document, batchCheckboxClassName, 'change', () => {
  const checkAllElement = document.querySelector('#batch_checkbox_all');
  const selectAllMatchingElement = document.querySelector('.batch-table__select-all');

  if (checkAllElement) {
    checkAllElement.checked = [].every.call(document.querySelectorAll(batchCheckboxClassName), (content) => content.checked);
    checkAllElement.indeterminate = !checkAllElement.checked && [].some.call(document.querySelectorAll(batchCheckboxClassName), (content) => content.checked);

    if (selectAllMatchingElement) {
      if (checkAllElement.checked) {
        showSelectAll();
      } else {
        hideSelectAll();
      }
    }
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
      bootstrapTimelineAccountsField.parentElement.parentElement.classList.remove('disabled');
    } else {
      bootstrapTimelineAccountsField.parentElement.classList.add('disabled');
      bootstrapTimelineAccountsField.parentElement.parentElement.classList.add('disabled');
    }
  }
};

delegate(document, '#form_admin_settings_enable_bootstrap_timeline_accounts', 'change', ({ target }) => onEnableBootstrapTimelineAccountsChange(target));

const onChangeRegistrationMode = (target) => {
  const enabled = target.value === 'approved';

  [].forEach.call(document.querySelectorAll('#form_admin_settings_require_invite_text'), (input) => {
    input.disabled = !enabled;
    if (enabled) {
      let element = input;
      do {
        element.classList.remove('disabled');
        element = element.parentElement;
      } while (element && !element.classList.contains('fields-group'));
    } else {
      let element = input;
      do {
        element.classList.add('disabled');
        element = element.parentElement;
      } while (element && !element.classList.contains('fields-group'));
    }
  });
};

const convertUTCDateTimeToLocal = (value) => {
  const date = new Date(value + 'Z');
  const twoChars = (x) => (x.toString().padStart(2, '0'));
  return `${date.getFullYear()}-${twoChars(date.getMonth()+1)}-${twoChars(date.getDate())}T${twoChars(date.getHours())}:${twoChars(date.getMinutes())}`;
};

const convertLocalDatetimeToUTC = (value) => {
  const re = /^([0-9]{4,})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2})/;
  const match = re.exec(value);
  const date = new Date(match[1], match[2] - 1, match[3], match[4], match[5]);
  const fullISO8601 = date.toISOString();
  return fullISO8601.slice(0, fullISO8601.indexOf('T') + 6);
};

delegate(document, '#form_admin_settings_registrations_mode', 'change', ({ target }) => onChangeRegistrationMode(target));

ready(() => {
  const domainBlockSeverityInput = document.getElementById('domain_block_severity');
  if (domainBlockSeverityInput) onDomainBlockSeverityChange(domainBlockSeverityInput);

  const enableBootstrapTimelineAccounts = document.getElementById('form_admin_settings_enable_bootstrap_timeline_accounts');
  if (enableBootstrapTimelineAccounts) onEnableBootstrapTimelineAccountsChange(enableBootstrapTimelineAccounts);

  const registrationMode = document.getElementById('form_admin_settings_registrations_mode');
  if (registrationMode) onChangeRegistrationMode(registrationMode);

  const checkAllElement = document.querySelector('#batch_checkbox_all');
  if (checkAllElement) {
    checkAllElement.checked = [].every.call(document.querySelectorAll(batchCheckboxClassName), (content) => content.checked);
    checkAllElement.indeterminate = !checkAllElement.checked && [].some.call(document.querySelectorAll(batchCheckboxClassName), (content) => content.checked);
  }

  document.querySelector('a#add-instance-button')?.addEventListener('click', (e) => {
    const domain = document.querySelector('input[type="text"]#by_domain')?.value;

    if (domain) {
      const url = new URL(event.target.href);
      url.searchParams.set('_domain', domain);
      e.target.href = url;
    }
  });

  [].forEach.call(document.querySelectorAll('input[type="datetime-local"]'), element => {
    if (element.value) {
      element.value = convertUTCDateTimeToLocal(element.value);
    }
    if (element.placeholder) {
      element.placeholder = convertUTCDateTimeToLocal(element.placeholder);
    }
  });

  delegate(document, 'form', 'submit', ({ target }) => {
    [].forEach.call(target.querySelectorAll('input[type="datetime-local"]'), element => {
      if (element.value && element.validity.valid) {
        element.value = convertLocalDatetimeToUTC(element.value);
      }
    });
  });

  const announcementStartsAt = document.querySelector('input[type="datetime-local"]#announcement_starts_at');
  if (announcementStartsAt) {
    setAnnouncementEndsAttributes(announcementStartsAt);
  }

  const React    = require('react');
  const ReactDOM = require('react-dom');

  [].forEach.call(document.querySelectorAll('[data-admin-component]'), element => {
    const componentName  = element.getAttribute('data-admin-component');
    const { locale, ...componentProps } = JSON.parse(element.getAttribute('data-props'));

    import('../mastodon/containers/admin_component').then(({ default: AdminComponent }) => {
      return import('../mastodon/components/admin/' + componentName).then(({ default: Component }) => {
        ReactDOM.render((
          <AdminComponent locale={locale}>
            <Component {...componentProps} />
          </AdminComponent>
        ), element);
      });
    }).catch(error => {
      console.error(error);
    });
  });
});
