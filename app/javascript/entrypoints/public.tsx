import { createRoot } from 'react-dom/client';

import { IntlMessageFormat } from 'intl-messageformat';
import type { MessageDescriptor, PrimitiveType } from 'react-intl';
import { defineMessages } from 'react-intl';

import axios from 'axios';
import { on } from 'delegated-events';
import { throttle } from 'lodash';

import { timeAgoString } from '../mastodon/components/relative_timestamp';
import emojify from '../mastodon/features/emoji/emoji';
import loadKeyboardExtensions from '../mastodon/load_keyboard_extensions';
import { loadLocale, getLocale } from '../mastodon/locales';
import { loadPolyfills } from '../mastodon/polyfills';
import ready from '../mastodon/ready';

import 'cocoon-js-vanilla';

const messages = defineMessages({
  usernameTaken: {
    id: 'username.taken',
    defaultMessage: 'That username is taken. Try another',
  },
  passwordExceedsLength: {
    id: 'password_confirmation.exceeds_maxlength',
    defaultMessage: 'Password confirmation exceeds the maximum password length',
  },
  passwordDoesNotMatch: {
    id: 'password_confirmation.mismatching',
    defaultMessage: 'Password confirmation does not match',
  },
});

function loaded() {
  const { messages: localeData } = getLocale();

  const locale = document.documentElement.lang;

  const dateTimeFormat = new Intl.DateTimeFormat(locale, {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: 'numeric',
    minute: 'numeric',
  });

  const dateFormat = new Intl.DateTimeFormat(locale, {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  });

  const timeFormat = new Intl.DateTimeFormat(locale, {
    timeStyle: 'short',
  });

  const formatMessage = (
    { id, defaultMessage }: MessageDescriptor,
    values?: Record<string, PrimitiveType>,
  ) => {
    let message: string | undefined = undefined;

    if (id) message = localeData[id];

    message ??= defaultMessage as string;

    const messageFormat = new IntlMessageFormat(message, locale);
    return messageFormat.format(values) as string;
  };

  document.querySelectorAll('.emojify').forEach((content) => {
    content.innerHTML = emojify(content.innerHTML);
  });

  document
    .querySelectorAll<HTMLTimeElement>('time.formatted')
    .forEach((content) => {
      const datetime = new Date(content.dateTime);
      const formattedDate = dateTimeFormat.format(datetime);

      content.title = formattedDate;
      content.textContent = formattedDate;
    });

  const isToday = (date: Date) => {
    const today = new Date();

    return (
      date.getDate() === today.getDate() &&
      date.getMonth() === today.getMonth() &&
      date.getFullYear() === today.getFullYear()
    );
  };
  const todayFormat = new IntlMessageFormat(
    localeData['relative_format.today'] ?? 'Today at {time}',
    locale,
  );

  document
    .querySelectorAll<HTMLTimeElement>('time.relative-formatted')
    .forEach((content) => {
      const datetime = new Date(content.dateTime);

      let formattedContent: string;

      if (isToday(datetime)) {
        const formattedTime = timeFormat.format(datetime);

        formattedContent = todayFormat.format({
          time: formattedTime,
        }) as string;
      } else {
        formattedContent = dateFormat.format(datetime);
      }

      const timeGiven = content.dateTime.includes('T');
      content.title = timeGiven
        ? dateTimeFormat.format(datetime)
        : dateFormat.format(datetime);

      content.textContent = formattedContent;
    });

  document
    .querySelectorAll<HTMLTimeElement>('time.time-ago')
    .forEach((content) => {
      const datetime = new Date(content.dateTime);
      const now = new Date();

      const timeGiven = content.dateTime.includes('T');
      content.title = timeGiven
        ? dateTimeFormat.format(datetime)
        : dateFormat.format(datetime);
      content.textContent = timeAgoString(
        {
          formatMessage,
          formatDate: (date: Date, options) =>
            new Intl.DateTimeFormat(locale, options).format(date),
        },
        datetime,
        now.getTime(),
        now.getFullYear(),
        timeGiven,
      );
    });

  updateDefaultQuotePrivacyFromPrivacy(
    document.querySelector('#user_settings_attributes_default_privacy'),
  );

  const reactComponents = document.querySelectorAll('[data-component]');

  if (reactComponents.length > 0) {
    import('../mastodon/containers/media_container')
      .then(({ default: MediaContainer }) => {
        reactComponents.forEach((component) => {
          Array.from(component.children).forEach((child) => {
            component.removeChild(child);
          });
        });

        const content = document.createElement('div');

        const root = createRoot(content);
        root.render(
          <MediaContainer locale={locale} components={reactComponents} />,
        );
        document.body.appendChild(content);

        return true;
      })
      .catch((error: unknown) => {
        console.error(error);
      });
  }

  on(
    'input',
    'input#user_account_attributes_username',
    throttle(
      ({ target }) => {
        if (!(target instanceof HTMLInputElement)) return;

        if (target.value && target.value.length > 0) {
          axios
            .get('/api/v1/accounts/lookup', { params: { acct: target.value } })
            .then(() => {
              target.setCustomValidity(formatMessage(messages.usernameTaken));
              return true;
            })
            .catch(() => {
              target.setCustomValidity('');
            });
        } else {
          target.setCustomValidity('');
        }
      },
      500,
      { leading: false, trailing: true },
    ),
  );

  on('input', '#user_password,#user_password_confirmation', () => {
    const password = document.querySelector<HTMLInputElement>(
      'input#user_password',
    );
    const confirmation = document.querySelector<HTMLInputElement>(
      'input#user_password_confirmation',
    );
    if (!confirmation || !password) return;

    if (confirmation.value && confirmation.value.length > password.maxLength) {
      confirmation.setCustomValidity(
        formatMessage(messages.passwordExceedsLength),
      );
    } else if (password.value && password.value !== confirmation.value) {
      confirmation.setCustomValidity(
        formatMessage(messages.passwordDoesNotMatch),
      );
    } else {
      confirmation.setCustomValidity('');
    }
  });
}

on('change', '#edit_profile input[type=file]', ({ target }) => {
  if (!(target instanceof HTMLInputElement)) return;

  const avatar = document.querySelector<HTMLImageElement>(
    `img#${target.id}-preview`,
  );

  if (!avatar) return;

  let file: File | undefined;
  if (target.files) file = target.files[0];

  const url = file ? URL.createObjectURL(file) : avatar.dataset.originalSrc;

  if (url) avatar.src = url;
});

on('click', '.input-copy input', ({ target }) => {
  if (!(target instanceof HTMLInputElement)) return;

  target.focus();
  target.select();
  target.setSelectionRange(0, target.value.length);
});

on('click', '.input-copy button', ({ target }) => {
  if (!(target instanceof HTMLButtonElement)) return;

  const input = target.parentNode?.querySelector<HTMLInputElement>(
    '.input-copy__wrapper input',
  );

  if (!input) return;

  navigator.clipboard
    .writeText(input.value)
    .then(() => {
      const parent = target.parentElement;

      if (parent) {
        parent.classList.add('copied');

        setTimeout(() => {
          parent.classList.remove('copied');
        }, 700);
      }

      return true;
    })
    .catch((error: unknown) => {
      console.error(error);
    });
});

const toggleSidebar = () => {
  const sidebar = document.querySelector<HTMLUListElement>('.sidebar ul');
  const toggleButton = document.querySelector<HTMLAnchorElement>(
    'a.sidebar__toggle__icon',
  );

  if (!sidebar || !toggleButton) return;

  if (sidebar.classList.contains('visible')) {
    document.body.style.overflow = '';
    toggleButton.setAttribute('aria-expanded', 'false');
  } else {
    document.body.style.overflow = 'hidden';
    toggleButton.setAttribute('aria-expanded', 'true');
  }

  toggleButton.classList.toggle('active');
  sidebar.classList.toggle('visible');
};

on('click', '.sidebar__toggle__icon', () => {
  toggleSidebar();
});

on('keydown', '.sidebar__toggle__icon', (e) => {
  if (e.key === ' ' || e.key === 'Enter') {
    e.preventDefault();
    toggleSidebar();
  }
});

on('mouseover', 'img.custom-emoji', ({ target }) => {
  if (target instanceof HTMLImageElement && target.dataset.original)
    target.src = target.dataset.original;
});
on('mouseout', 'img.custom-emoji', ({ target }) => {
  if (target instanceof HTMLImageElement && target.dataset.static)
    target.src = target.dataset.static;
});

const setInputDisabled = (
  input: HTMLInputElement | HTMLSelectElement,
  disabled: boolean,
) => {
  input.disabled = disabled;

  const wrapper = input.closest('.with_label');
  if (wrapper) {
    wrapper.classList.toggle('disabled', input.disabled);

    const hidden =
      input.type === 'checkbox' &&
      wrapper.querySelector<HTMLInputElement>('input[type=hidden][value="0"]');
    if (hidden) {
      hidden.disabled = input.disabled;
    }
  }
};

const setInputHint = (
  input: HTMLInputElement | HTMLSelectElement,
  hintPrefix: string,
) => {
  const fieldWrapper = input.closest<HTMLElement>('.fields-group > .input');
  if (!fieldWrapper) return;

  const hint = fieldWrapper.dataset[`${hintPrefix}Hint`];
  const hintElement =
    fieldWrapper.querySelector<HTMLSpanElement>(':scope > .hint');

  if (hint) {
    if (hintElement) {
      hintElement.textContent = hint;
    } else {
      const newHintElement = document.createElement('span');
      newHintElement.className = 'hint';
      newHintElement.textContent = hint;
      fieldWrapper.appendChild(newHintElement);
    }
  } else {
    hintElement?.remove();
  }
};

on('change', '#account_statuses_cleanup_policy_enabled', ({ target }) => {
  if (!(target instanceof HTMLInputElement) || !target.form) return;

  target.form
    .querySelectorAll<HTMLInputElement | HTMLSelectElement>(
      'input:not([type=hidden], #account_statuses_cleanup_policy_enabled), select',
    )
    .forEach((input) => {
      setInputDisabled(input, !target.checked);
    });
});

const updateDefaultQuotePrivacyFromPrivacy = (
  privacySelect: EventTarget | null,
) => {
  if (!(privacySelect instanceof HTMLSelectElement) || !privacySelect.form)
    return;

  const select = privacySelect.form.querySelector<HTMLSelectElement>(
    'select#user_settings_attributes_default_quote_policy',
  );
  if (!select) return;

  setInputHint(select, privacySelect.value);

  if (privacySelect.value === 'private') {
    select.value = 'nobody';
    setInputDisabled(select, true);
  } else {
    setInputDisabled(select, false);
  }
};

on('change', '#user_settings_attributes_default_privacy', ({ target }) => {
  updateDefaultQuotePrivacyFromPrivacy(target);
});

// Empty the honeypot fields in JS in case something like an extension
// automatically filled them.
on('submit', '#registration_new_user,#new_user', () => {
  [
    'user_website',
    'user_confirm_password',
    'registration_user_website',
    'registration_user_confirm_password',
  ].forEach((id) => {
    const field = document.querySelector<HTMLInputElement>(`input#${id}`);
    if (field) {
      field.value = '';
    }
  });
});

on('click', '.rules-list button', ({ target }) => {
  if (!(target instanceof HTMLElement)) {
    return;
  }

  const button = target.closest('button');

  if (!button) {
    return;
  }

  if (button.ariaExpanded === 'true') {
    button.ariaExpanded = 'false';
  } else {
    button.ariaExpanded = 'true';
  }
});

function main() {
  ready(loaded).catch((error: unknown) => {
    console.error(error);
  });
}

loadPolyfills()
  .then(loadLocale)
  .then(main)
  .then(loadKeyboardExtensions)
  .catch((error: unknown) => {
    console.error(error);
  });
