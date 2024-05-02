import 'packs/public-path';
import { createRoot } from 'react-dom/client';

import Rails from '@rails/ujs';

import ready from 'flavours/glitch/ready';

const setAnnouncementEndsAttributes = (target: HTMLInputElement) => {
  const valid = target.value && target.validity.valid;
  const element = document.querySelector<HTMLInputElement>(
    'input[type="datetime-local"]#announcement_ends_at',
  );

  if (!element) return;

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

Rails.delegate(
  document,
  'input[type="datetime-local"]#announcement_starts_at',
  'change',
  ({ target }) => {
    if (target instanceof HTMLInputElement)
      setAnnouncementEndsAttributes(target);
  },
);

const batchCheckboxClassName = '.batch-checkbox input[type="checkbox"]';

const showSelectAll = () => {
  const selectAllMatchingElement = document.querySelector(
    '.batch-table__select-all',
  );
  selectAllMatchingElement?.classList.add('active');
};

const hideSelectAll = () => {
  const selectAllMatchingElement = document.querySelector(
    '.batch-table__select-all',
  );
  const hiddenField = document.querySelector<HTMLInputElement>(
    'input#select_all_matching',
  );
  const selectedMsg = document.querySelector(
    '.batch-table__select-all .selected',
  );
  const notSelectedMsg = document.querySelector(
    '.batch-table__select-all .not-selected',
  );

  selectAllMatchingElement?.classList.remove('active');
  selectedMsg?.classList.remove('active');
  notSelectedMsg?.classList.add('active');
  if (hiddenField) hiddenField.value = '0';
};

Rails.delegate(document, '#batch_checkbox_all', 'change', ({ target }) => {
  if (!(target instanceof HTMLInputElement)) return;

  const selectAllMatchingElement = document.querySelector(
    '.batch-table__select-all',
  );

  document
    .querySelectorAll<HTMLInputElement>(batchCheckboxClassName)
    .forEach((content) => {
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

Rails.delegate(document, '.batch-table__select-all button', 'click', () => {
  const hiddenField = document.querySelector<HTMLInputElement>(
    '#select_all_matching',
  );

  if (!hiddenField) return;

  const active = hiddenField.value === '1';
  const selectedMsg = document.querySelector(
    '.batch-table__select-all .selected',
  );
  const notSelectedMsg = document.querySelector(
    '.batch-table__select-all .not-selected',
  );

  if (!selectedMsg || !notSelectedMsg) return;

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

Rails.delegate(document, batchCheckboxClassName, 'change', () => {
  const checkAllElement = document.querySelector<HTMLInputElement>(
    'input#batch_checkbox_all',
  );
  const selectAllMatchingElement = document.querySelector(
    '.batch-table__select-all',
  );

  if (checkAllElement) {
    const allCheckboxes = Array.from(
      document.querySelectorAll<HTMLInputElement>(batchCheckboxClassName),
    );
    checkAllElement.checked = allCheckboxes.every((content) => content.checked);
    checkAllElement.indeterminate =
      !checkAllElement.checked &&
      allCheckboxes.some((content) => content.checked);

    if (selectAllMatchingElement) {
      if (checkAllElement.checked) {
        showSelectAll();
      } else {
        hideSelectAll();
      }
    }
  }
});

Rails.delegate(
  document,
  '.filter-subset--with-select select',
  'change',
  ({ target }) => {
    if (target instanceof HTMLSelectElement) target.form?.submit();
  },
);

const onDomainBlockSeverityChange = (target: HTMLSelectElement) => {
  const rejectMediaDiv = document.querySelector(
    '.input.with_label.domain_block_reject_media',
  );
  const rejectReportsDiv = document.querySelector(
    '.input.with_label.domain_block_reject_reports',
  );

  if (rejectMediaDiv && rejectMediaDiv instanceof HTMLElement) {
    rejectMediaDiv.style.display =
      target.value === 'suspend' ? 'none' : 'block';
  }

  if (rejectReportsDiv && rejectReportsDiv instanceof HTMLElement) {
    rejectReportsDiv.style.display =
      target.value === 'suspend' ? 'none' : 'block';
  }
};

Rails.delegate(document, '#domain_block_severity', 'change', ({ target }) => {
  if (target instanceof HTMLSelectElement) onDomainBlockSeverityChange(target);
});

const onEnableBootstrapTimelineAccountsChange = (target: HTMLInputElement) => {
  const bootstrapTimelineAccountsField =
    document.querySelector<HTMLInputElement>(
      '#form_admin_settings_bootstrap_timeline_accounts',
    );

  if (bootstrapTimelineAccountsField) {
    bootstrapTimelineAccountsField.disabled = !target.checked;
    if (target.checked) {
      bootstrapTimelineAccountsField.parentElement?.classList.remove(
        'disabled',
      );
      bootstrapTimelineAccountsField.parentElement?.parentElement?.classList.remove(
        'disabled',
      );
    } else {
      bootstrapTimelineAccountsField.parentElement?.classList.add('disabled');
      bootstrapTimelineAccountsField.parentElement?.parentElement?.classList.add(
        'disabled',
      );
    }
  }
};

Rails.delegate(
  document,
  '#form_admin_settings_enable_bootstrap_timeline_accounts',
  'change',
  ({ target }) => {
    if (target instanceof HTMLInputElement)
      onEnableBootstrapTimelineAccountsChange(target);
  },
);

const onChangeRegistrationMode = (target: HTMLSelectElement) => {
  const enabled = target.value === 'approved';

  document
    .querySelectorAll<HTMLElement>(
      '.form_admin_settings_registrations_mode .warning-hint',
    )
    .forEach((warning_hint) => {
      warning_hint.style.display = target.value === 'open' ? 'inline' : 'none';
    });

  document
    .querySelectorAll<HTMLInputElement>(
      'input#form_admin_settings_require_invite_text',
    )
    .forEach((input) => {
      input.disabled = !enabled;
      if (enabled) {
        let element: HTMLElement | null = input;
        do {
          element.classList.remove('disabled');
          element = element.parentElement;
        } while (element && !element.classList.contains('fields-group'));
      } else {
        let element: HTMLElement | null = input;
        do {
          element.classList.add('disabled');
          element = element.parentElement;
        } while (element && !element.classList.contains('fields-group'));
      }
    });
};

const convertUTCDateTimeToLocal = (value: string) => {
  const date = new Date(value + 'Z');
  const twoChars = (x: number) => x.toString().padStart(2, '0');
  return `${date.getFullYear()}-${twoChars(date.getMonth() + 1)}-${twoChars(date.getDate())}T${twoChars(date.getHours())}:${twoChars(date.getMinutes())}`;
};

function convertLocalDatetimeToUTC(value: string) {
  const date = new Date(value);
  const fullISO8601 = date.toISOString();
  return fullISO8601.slice(0, fullISO8601.indexOf('T') + 6);
}

Rails.delegate(
  document,
  '#form_admin_settings_registrations_mode',
  'change',
  ({ target }) => {
    if (target instanceof HTMLSelectElement) onChangeRegistrationMode(target);
  },
);

async function mountReactComponent(element: Element) {
  const componentName = element.getAttribute('data-admin-component');
  const stringProps = element.getAttribute('data-props');

  if (!stringProps) return;

  const componentProps = JSON.parse(stringProps) as object;

  const { default: AdminComponent } = await import(
    '@/flavours/glitch/containers/admin_component'
  );

  const { default: Component } = (await import(
    `@/flavours/glitch/components/admin/${componentName}`
  )) as { default: React.ComponentType };

  const root = createRoot(element);

  root.render(
    <AdminComponent>
      <Component {...componentProps} />
    </AdminComponent>,
  );
}

ready(() => {
  const domainBlockSeveritySelect = document.querySelector<HTMLSelectElement>(
    'select#domain_block_severity',
  );
  if (domainBlockSeveritySelect)
    onDomainBlockSeverityChange(domainBlockSeveritySelect);

  const enableBootstrapTimelineAccounts =
    document.querySelector<HTMLInputElement>(
      'input#form_admin_settings_enable_bootstrap_timeline_accounts',
    );
  if (enableBootstrapTimelineAccounts)
    onEnableBootstrapTimelineAccountsChange(enableBootstrapTimelineAccounts);

  const registrationMode = document.querySelector<HTMLSelectElement>(
    'select#form_admin_settings_registrations_mode',
  );
  if (registrationMode) onChangeRegistrationMode(registrationMode);

  const checkAllElement = document.querySelector<HTMLInputElement>(
    'input#batch_checkbox_all',
  );
  if (checkAllElement) {
    const allCheckboxes = Array.from(
      document.querySelectorAll<HTMLInputElement>(batchCheckboxClassName),
    );
    checkAllElement.checked = allCheckboxes.every((content) => content.checked);
    checkAllElement.indeterminate =
      !checkAllElement.checked &&
      allCheckboxes.some((content) => content.checked);
  }

  document
    .querySelector('a#add-instance-button')
    ?.addEventListener('click', (e) => {
      const domain = document.querySelector<HTMLInputElement>(
        'input[type="text"]#by_domain',
      )?.value;

      if (domain && e.target instanceof HTMLAnchorElement) {
        const url = new URL(e.target.href);
        url.searchParams.set('_domain', domain);
        e.target.href = url.toString();
      }
    });

  document
    .querySelectorAll<HTMLInputElement>('input[type="datetime-local"]')
    .forEach((element) => {
      if (element.value) {
        element.value = convertUTCDateTimeToLocal(element.value);
      }
      if (element.placeholder) {
        element.placeholder = convertUTCDateTimeToLocal(element.placeholder);
      }
    });

  Rails.delegate(document, 'form', 'submit', ({ target }) => {
    if (target instanceof HTMLFormElement)
      target
        .querySelectorAll<HTMLInputElement>('input[type="datetime-local"]')
        .forEach((element) => {
          if (element.value && element.validity.valid) {
            element.value = convertLocalDatetimeToUTC(element.value);
          }
        });
  });

  const announcementStartsAt = document.querySelector<HTMLInputElement>(
    'input[type="datetime-local"]#announcement_starts_at',
  );
  if (announcementStartsAt) {
    setAnnouncementEndsAttributes(announcementStartsAt);
  }

  document.querySelectorAll('[data-admin-component]').forEach((element) => {
    void mountReactComponent(element);
  });
}).catch((reason: unknown) => {
  throw reason;
});
