import { createRoot } from 'react-dom/client';

import 'packs/public-path';

import { IntlMessageFormat } from 'intl-messageformat';
import type { MessageDescriptor, PrimitiveType } from 'react-intl';
import { defineMessages } from 'react-intl';

import Rails from '@rails/ujs';
import axios from 'axios';
import { throttle } from 'lodash';

import { timeAgoString } from 'flavours/glitch/components/relative_timestamp';
import emojify from 'flavours/glitch/features/emoji/emoji';
import loadKeyboardExtensions from 'flavours/glitch/load_keyboard_extensions';
import { loadLocale, getLocale } from 'flavours/glitch/locales';
import { loadPolyfills } from 'flavours/glitch/polyfills';
import ready from 'flavours/glitch/ready';

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
      .catch((error) => {
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
  ready(loaded).catch((error) => {
    console.error(error);
  });
}

loadPolyfills()
  .then(loadLocale)
  .then(main)
  .then(loadKeyboardExtensions)
  .catch((error) => {
    console.error(error);
  });
