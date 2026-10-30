# frozen_string_literal: true

require 'rails_helper'
require 'character_counter'

RSpec.describe CharacterCounter do
  subject { described_class.new }

  context 'when note is too long' do
    let(:too_long) { 'a' * 200 }

    it { expect(subject.countable_text(too_long)).to eq(too_long) }
  end

  context 'when note has space separated linkable URLs' do
    let(:text) { [starting_string, example_link].join(' ') }

    it { expect(subject.countable_text(text)).to eq([starting_string, url_placeholder].join(' ')) }
  end

  context 'when note has non-separated URLs' do
    let(:text) { [starting_string, example_link].join }

    it { expect(subject.countable_text(text)).to eq(text) }
  end

  context 'with multiline text and mentions and URL' do
    let(:text) do
      <<~TEXT
        great day here with @mause@bart

        https://maus.social/jolly-link
      TEXT
    end

    it { expect(subject.countable_text(text)).to include("great day here with @mause\n\n#{url_placeholder}\n") }
  end

  context 'with multi-byte emoji' do
    let(:text) { '✨' * 100 }

    it { expect(subject.countable_text(text)).to eq(text) }
  end

  context 'with ZWJ sequence emoji' do
    let(:text) { '🏳️‍⚧️' * 100 }

    it { expect(subject.countable_text(text)).to eq(text) }
  end

  context 'when text and content warning combine to exceed limit' do
    let(:text) { 'a' * 50 }

    it { expect(subject.countable_text(text)).to eq(text) }
  end

  context 'with long URLs' do
    let(:text) { "http://example.com/something#{'?valid=foo' * 10}" }

    it { expect(subject.countable_text(text)).to eq(url_placeholder) }
  end

  context 'with excessively long URLs' do
    let(:text) { "http://example.com/something#{'?valid=foo' * 1000}" }

    it { expect(subject.countable_text(text)).to eq(text) }
  end

  context 'when remote account usernames cause limit excess' do
    let(:text) { ('a' * 75) + " @alice@#{'b' * 30}.com" }

    it { expect(subject.countable_text(text)).to eq("#{'a' * 75} @alice") }
  end

  context 'when remote usernames are attached to long domains' do
    let(:text) { "@alice@#{'b' * Extractor::MAX_DOMAIN_LENGTH * 2}.com" }

    it { expect(subject.countable_text(text)).to eq(text) }
  end

  context 'with the tests from the javascript counter class to validate same behaviour' do
    describe 'passes plain text through unchanged' do
      it { expect(subject.countable_text('hello world')).to eq('hello world') }
    end

    describe 'collapses an https URL to a 23-character placeholder' do
      it { expect(subject.countable_text('see https://example.com here')).to eq("see #{url_placeholder} here") }
    end

    describe 'collapses a schemaless URL the same way' do
      it { expect(subject.countable_text('see example.com here')).to eq("see #{url_placeholder} here") }
    end

    describe 'collapses a non-BMP URL the same way' do
      it { expect(subject.countable_text('look https://example.com/🐪/#camel here')).to eq("look #{url_placeholder} here") }
    end

    describe 'collapses a schemaless non-BMP URL the same way' do
      it { expect(subject.countable_text('look example.com/🐪/#camel here')).to eq("look #{url_placeholder} here") }
    end

    describe 'collapses an IDN URL the same way' do
      it { expect(subject.countable_text('besøk https://grå.org/ idag')).to eq("besøk #{url_placeholder} idag") }
    end

    describe 'collapses an IDN URL with non-Latin script' do
      it { expect(subject.countable_text('参观 https://慕田峪长城.网址/ 今天')).to eq("参观 #{url_placeholder} 今天") }
    end

    describe 'strips the host part of an ASCII remote mention' do
      it { expect(subject.countable_text('hi @bob@example.com')).to eq('hi @bob') }
    end

    describe 'does not touch a local mention' do
      it { expect(subject.countable_text('hi @bob')).to eq('hi @bob') }
    end

    describe 'handles a URL and a mention together' do
      it { expect(subject.countable_text('@bob@example.com look https://example.com')).to eq("@bob look #{url_placeholder}") }
    end

    describe 'email-shaped text is left alone (no leading @, so not a mention)' do
      it { expect(subject.countable_text('mail arnt@grå.org for details')).to eq('mail arnt@grå.org for details') }
    end

    describe 'strips a Latin-IDN remote mention' do
      it { expect(subject.countable_text('hi @arnt@grå.org')).to eq('hi @arnt') }
    end

    describe 'strips a CJK-IDN remote mention' do
      it { expect(subject.countable_text('hi @user@慕田峪长城.网址')).to eq('hi @user') }
    end

    describe 'leaves a mention with an implausible host alone' do
      it { expect(subject.countable_text('@arnt@invalid')).to eq('@arnt') }
    end

    describe 'iterate through funky domains' do
      # UASG-004 universal-acceptance domains (one per script), plus a
      # Tibetan example. Each  domain should be recognized both as a bare
      # URL and as the host half of a remote mention.
      let(:funky_domains) do
        [
          'universal-acceptance-test.international', # long ASCII
          'universal-acceptance-test.icu', # short ASCII
          'تجربة-القبول-الشامل.موريتانيا', # Arabic, RTL
          'համընդհանուր-ընկալում-թեստ.հայ', # Armenian
          'সর্বজনীন-স্বীকৃতির-পরীক্ষা.ভারত', # Bengali
          'универсальное-принятие-тест.москва', # Cyrillic
          'सार्वभौमिक-स्वीकृति-परीक्षण.संगठन', # Devanagari
          'უნივერსალური-თავსობადობის-ტესტი.გე', # Georgian
          'καθολική-αποδοχή-δοκιμή.ευ', # Greek
          'સાર્વત્રિક-સ્વીકૃતિ-પરીક્ષણ.ભારત', # Gujarati
          'ਸਰਵਵਿਆਪਕ-ਪ੍ਰਵਾਨਗੀ-ਪਰਖ.ਭਾਰਤ', # Gurmukhi
          '다국어도메인이용환경테스트.한국', # Hangul
          'מבחן-קבלה-אוניברסלי.קום', # Hebrew, RTL
          'どこでもつかえる.みんな', # Hiragana
          'ಸಾರ್ವತ್ರಿಕ-ಸ್ವೀಕಾರಾರ್ಹತೆ-ಪರೀಕ್ಷೆ.ಭಾರತ', # Kannada
          'ユニバーサルアクセプタンス.クラウド', # Katakana
          'ສາກົນ-ການຍອມຮັບ-ທົດລອງ.ລາວ', # Lao
          'സാർവത്രിക-സ്വീകാര്യതാ-പരിശോധന.ഭാരതം', # Malayalam
          'ଯୁନିଭରସାଲ-ଏକସେପ୍ଟନ୍ସ-ଟେଷ୍ଟ.ଭାରତ', # Oriya
          'විශ්ව-සම්මුති-පිරික්සුම.ලංකා', # Sinhala
          'பொது-ஏற்பு-சோதனை.சிங்கப்பூர்', # Tamil
          'యూనివర్సల్-ఆమోదం-పరీక్ష.భారత్', # Telugu
          'ยูเอทดสอบ.ไทย', # Thai
          '普遍适用测试.我爱你', # Simplified Chinese
          '普遍適用測試.台灣', # Traditional Chinese
          'ሁለንአቀፍ-ተቀባይነት-ሙከራ.com', # Ethiopic
          'ការសាកល្បងទទួលយកជាអន្តរជាតិ.com', # Khmer
          'အလုံးစုံလက်ခံမှုစမ်းသပ်ချက်.com', # Myanmar
          'ދުނިޔެ-ގަބޫލުކުރާ-ޓެސްޓު.com', # Thaana, RTL
          'universal-acceptance-test.קום', # ASCII.IDN Hebrew
          'épreuve-acceptation-universelle.org', # Latin with accent
          'ཡོངས་ཁྱབ་ངོས་ལེན་བརྟག་དཔྱད.com', # Tibetan
        ]
      end

      it 'collapses a bare %s to a 23-character placeholder' do
        funky_domains.each do |domain|
          expect(subject.countable_text("look #{domain} here")).to eq("look #{url_placeholder} here")
        end
      end

      it 'strips the host of a remote mention @info@%s' do
        funky_domains.each do |domain|
          expect(subject.countable_text("@info@#{domain}")).to eq('@info')
        end
      end
    end
  end

  private

  def too_long_message
    I18n.t('errors.messages.too_long', count: 100)
  end

  def starting_string
    'a' * 76
  end

  def example_link
    "http://#{'b' * 30}.com/example"
  end

  def url_placeholder
    @url_placeholder = CharacterCounter::URL_PLACEHOLDER
  end
end
