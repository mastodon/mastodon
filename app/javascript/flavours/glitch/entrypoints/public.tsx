import { createRoot } from 'react-dom/client';

import '@/entrypoints/public-path';

import { IntlMessageFormat } from 'intl-messageformat';
import type { MessageDescriptor, PrimitiveType } from 'react-intl';
import { defineMessages } from 'react-intl';

import Rails from '@rails/ujs';
import axios from 'axios';
import { throttle } from 'lodash';

import { start } from 'flavours/glitch/common';
import { timeAgoString } from 'flavours/glitch/components/relative_timestamp';
import emojify from 'flavours/glitch/features/emoji/emoji';
import loadKeyboardExtensions from 'flavours/glitch/load_keyboard_extensions';
import { loadLocale, getLocale } from 'flavours/glitch/locales';
import { loadPolyfills } from 'flavours/glitch/polyfills';
import ready from 'flavours/glitch/ready';

import 'cocoon-js-vanilla';

start();

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

interface SetHeightMessage {
  type: 'setHeight';
  id: string;
  height: number;
}

function isSetHeightMessage(data: unknown): data is SetHeightMessage {
  if (
    data &&
    typeof data === 'object' &&
    'type' in data &&
    data.type === 'setHeight'
  )
    return true;
  else return false;
}

window.addEventListener('message', (e) => {
  // eslint-disable-next-line @typescript-eslint/no-unnecessary-condition -- typings are not correct, it can be null in very rare cases
  if (!e.data || !isSetHeightMessage(e.data) || !window.parent) return;

  const data = e.data;

  ready(() => {
    window.parent.postMessage(
      {
        type: 'setHeight',
        id: data.id,
        height: document.getElementsByTagName('html')[0].scrollHeight,
      },
      '*',
    );
  }).catch((e: unknown) => {
    console.error('Error in setHeightMessage postMessage', e);
  });
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

    if (!message) message = defaultMessage as string;

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
    localeData['relative_format.today'] || 'Today at {time}',
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

      content.title = formattedContent;
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

  const reactComponents = document.querySelectorAll('[data-component]');

  if (reactComponents.length > 0) {
    import(
      /* webpackChunkName: "containers/media_container" */ 'flavours/glitch/containers/media_container'
    )
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

  Rails.delegate(
    document,
    'input#user_account_attributes_username',
    'input',
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

  Rails.delegate(
    document,
    '#user_password,#user_password_confirmation',
    'input',
    () => {
      const password = document.querySelector<HTMLInputElement>(
        'input#user_password',
      );
      const confirmation = document.querySelector<HTMLInputElement>(
        'input#user_password_confirmation',
      );
      if (!confirmation || !password) return;

      if (
        confirmation.value &&
        confirmation.value.length > password.maxLength
      ) {
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
    },
  );

  Rails.delegate(
    document,
    'button.status__content__spoiler-link',
    'click',
    function () {
      if (!(this instanceof HTMLButtonElement)) return;

      const statusEl = this.parentNode?.parentNode;

      if (
        !(
          statusEl instanceof HTMLDivElement &&
          statusEl.classList.contains('.status__content')
        )
      )
        return;

      if (statusEl.dataset.spoiler === 'expanded') {
        statusEl.dataset.spoiler = 'folded';
        this.textContent = new IntlMessageFormat(
          localeData['status.show_more'] || 'Show more',
          locale,
        ).format() as string;
      } else {
        statusEl.dataset.spoiler = 'expanded';
        this.textContent = new IntlMessageFormat(
          localeData['status.show_less'] || 'Show less',
          locale,
        ).format() as string;
      }
    },
  );

  document
    .querySelectorAll<HTMLButtonElement>('button.status__content__spoiler-link')
    .forEach((spoilerLink) => {
      const statusEl = spoilerLink.parentNode?.parentNode;

      if (
        !(
          statusEl instanceof HTMLDivElement &&
          statusEl.classList.contains('.status__content')
        )
      )
        return;

      const message =
        statusEl.dataset.spoiler === 'expanded'
          ? localeData['status.show_less'] || 'Show less'
          : localeData['status.show_more'] || 'Show more';
      spoilerLink.textContent = new IntlMessageFormat(
        message,
        locale,
      ).format() as string;
    });
}

Rails.delegate(
  document,
  '#edit_profile input[type=file]',
  'change',
  ({ target }) => {
    if (!(target instanceof HTMLInputElement)) return;

    const avatar = document.querySelector<HTMLImageElement>(
      `img#${target.id}-preview`,
    );

    if (!avatar) return;

    let file: File | undefined;
    if (target.files) file = target.files[0];

    const url = file ? URL.createObjectURL(file) : avatar.dataset.originalSrc;

    if (url) avatar.src = url;
  },
);

Rails.delegate(document, '.input-copy input', 'click', ({ target }) => {
  if (!(target instanceof HTMLInputElement)) return;

  target.focus();
  target.select();
  target.setSelectionRange(0, target.value.length);
});

Rails.delegate(document, '.input-copy button', 'click', ({ target }) => {
  if (!(target instanceof HTMLButtonElement)) return;

  const input = target.parentNode?.querySelector<HTMLInputElement>(
    '.input-copy__wrapper input',
  );

  if (!input) return;

  const oldReadOnly = input.readOnly;

  input.readOnly = false;
  input.focus();
  input.select();
  input.setSelectionRange(0, input.value.length);

  try {
    if (document.execCommand('copy')) {
      input.blur();

      const parent = target.parentElement;

      if (!parent) return;
      parent.classList.add('copied');

      setTimeout(() => {
        parent.classList.remove('copied');
      }, 700);
    }
  } catch (err) {
    console.error(err);
  }

  input.readOnly = oldReadOnly;
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

Rails.delegate(document, '.sidebar__toggle__icon', 'click', () => {
  toggleSidebar();
});

Rails.delegate(document, '.sidebar__toggle__icon', 'keydown', (e) => {
  if (e.key === ' ' || e.key === 'Enter') {
    e.preventDefault();
    toggleSidebar();
  }
});

Rails.delegate(document, 'img.custom-emoji', 'mouseover', ({ target }) => {
  if (target instanceof HTMLImageElement && target.dataset.original)
    target.src = target.dataset.original;
});
Rails.delegate(document, 'img.custom-emoji', 'mouseout', ({ target }) => {
  if (target instanceof HTMLImageElement && target.dataset.static)
    target.src = target.dataset.static;
});

// Empty the honeypot fields in JS in case something like an extension
// automatically filled them.
Rails.delegate(document, '#registration_new_user,#new_user', 'submit', () => {
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
