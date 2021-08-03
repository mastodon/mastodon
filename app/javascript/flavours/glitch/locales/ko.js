import inherited from 'mastodon/locales/ko.json';

const messages = {
  'getting_started.open_source_notice': '글리치는 {Mastodon}의 자유 오픈소스 포크버전입니다. {github}에서 문제를 리포팅 하거나 기여를 할 수 있습니다.',
  'layout.auto': '자동',
  'layout.current_is': '현재 레이아웃:',
  'layout.desktop': '데스크탑',
  'layout.mobile': '모바일',
  'navigation_bar.app_settings': '앱 설정',
  'getting_started.onboarding': '둘러보기',
  'onboarding.page_one.federation': '{domain}은 마스토돈의 \'인스턴스\'입니다. 마스토돈은 하나의 거대한 소셜 네트워크를 만들기 위해 참여한 서버들의 네트워크입니다. 우린 이 서버들을 인스턴스라고 부릅니다.',
  'onboarding.page_one.welcome': '{domain}에 오신 것을 환영합니다!',
  'onboarding.page_six.github': '{domain}은 글리치를 통해 구동 됩니다. 글리치는 {Mastodon}의 {fork}입니다, 그리고 어떤 마스토돈 인스턴스나 앱과도 호환 됩니다. 글리치는 완전한 자유 오픈소스입니다. {github}에서 버그를 리포팅 하거나, 기능을 제안하거나, 코드를 기여할 수 있습니다.',
  'settings.auto_collapse': '자동으로 접기',
  'settings.auto_collapse_all': '모두',
  'settings.auto_collapse_lengthy': '긴 글',
  'settings.auto_collapse_media': '미디어 포함 글',
  'settings.auto_collapse_notifications': '알림',
  'settings.auto_collapse_reblogs': '부스트',
  'settings.auto_collapse_replies': '답글',
  'settings.show_action_bar': '접힌 글에 액션 버튼들 보이기',
  'settings.close': 'Close',
  'settings.collapsed_statuses': '접힌 글',
  'settings.enable_collapsed': '접힌 글 활성화',
  'settings.general': '일반',
  'settings.image_backgrounds': '이미지 배경',
  'settings.image_backgrounds_media': '접힌 글의 미디어 미리보기',
  'settings.image_backgrounds_users': '접힌 글에 이미지 배경 주기',
  'settings.media': '미디어',
  'settings.media_letterbox': '레터박스 미디어',
  'settings.media_fullwidth': '최대폭 미디어 미리보기',
  'settings.preferences': '사용자 설정',
  'settings.wide_view': '넓은 뷰 (데스크탑 모드 전용)',
  'settings.navbar_under': '내비바를 하단에 (모바일 전용)',
  'status.collapse': '접기',
  'status.uncollapse': '펼치기',

  'media_gallery.sensitive': '민감함',

  'favourite_modal.combo': '다음엔 {combo}를 눌러 건너뛸 수 있습니다',

  'home.column_settings.show_direct': 'DM 보여주기',

  'notification.markForDeletion': '삭제 마크',
  'notifications.clear': '내 알림 모두 지우기',
  'notifications.marked_clear_confirmation': '정말로 선택된 알림들을 영구적으로 삭제할까요?',
  'notifications.marked_clear': '선택된 알림 모두 삭제',

  'notification_purge.btn_all': '전체선택',
  'notification_purge.btn_none': '전체선택해제',
  'notification_purge.btn_invert': '선택반전',
  'notification_purge.btn_apply': '선택된 알림 삭제',

  'compose.attach.upload': '파일 업로드',
  'compose.attach.doodle': '뭔가 그려보세요',
  'compose.attach': '첨부…',

  'advanced_options.local-only.short': '로컬 전용',
  'advanced_options.local-only.long': '다른 인스턴스에 게시하지 않기',
  'advanced_options.local-only.tooltip': '이 글은 로컬 전용입니다',
  'advanced_options.icon_title': '고급 옵션',
  'advanced_options.threaded_mode.short': '글타래 모드',
  'advanced_options.threaded_mode.long': '글을 작성하고 자동으로 답글 열기',
  'advanced_options.threaded_mode.tooltip': '글타래 모드 활성화됨',
};

export default Object.assign({}, inherited, messages);
