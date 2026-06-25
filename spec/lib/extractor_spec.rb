# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Extractor do
  describe 'extract_mentions_or_lists_with_indices' do
    it 'returns an empty array if the given string does not have at signs' do
      text = 'a string without at signs'
      extracted = described_class.extract_mentions_or_lists_with_indices(text)
      expect(extracted).to eq []
    end

    it 'does not extract mentions which ends with particular characters' do
      text = '@screen_name@'
      extracted = described_class.extract_mentions_or_lists_with_indices(text)
      expect(extracted).to eq []
    end

    it 'returns mentions as an array' do
      text = '@screen_name'
      extracted = described_class.extract_mentions_or_lists_with_indices(text)
      expect(extracted).to eq [
        { screen_name: 'screen_name', indices: [0, 12] },
      ]
    end

    it 'yields mentions if a block is given' do
      text = '@screen_name'
      described_class.extract_mentions_or_lists_with_indices(text) do |screen_name, start_position, end_position|
        expect(screen_name).to eq 'screen_name'
        expect(start_position).to eq 0
        expect(end_position).to eq 12
      end
    end

    # UASG-004 universal-acceptance domains (one per script), plus a
    # Tibetan example. Copied from uts58's extractor_spec.rb. A mention
    # whose host is one of these should still be recognized.
    funky_domains = [
      'universal-acceptance-test.international',
      'universal-acceptance-test.icu',
      'تجربة-القبول-الشامل.موريتانيا',
      'համընդհանուր-ընկալում-թեստ.հայ',
      'সর্বজনীন-স্বীকৃতির-পরীক্ষা.ভারত',
      'универсальное-принятие-тест.москва',
      'सार्वभौमिक-स्वीकृति-परीक्षण.संगठन',
      'უნივერსალური-თავსობადობის-ტესტი.გე',
      'καθολική-αποδοχή-δοκιμή.ευ',
      'સાર્વત્રિક-સ્વીકૃતિ-પરીક્ષણ.ભારત',
      'ਸਰਵਵਿਆਪਕ-ਪ੍ਰਵਾਨਗੀ-ਪਰਖ.ਭਾਰਤ',
      '다국어도메인이용환경테스트.한국',
      'מבחן-קבלה-אוניברסלי.קום',
      'どこでもつかえる.みんな',
      'ಸಾರ್ವತ್ರಿಕ-ಸ್ವೀಕಾರಾರ್ಹತೆ-ಪರೀಕ್ಷೆ.ಭಾರತ',
      'ユニバーサルアクセプタンス.クラウド',
      'ສາກົນ-ການຍອມຮັບ-ທົດລອງ.ລາວ',
      'സാർവത്രിക-സ്വീകാര്യതാ-പരിശോധന.ഭാരതം',
      'ଯୁନିଭରସାଲ-ଏକସେପ୍ଟନ୍ସ-ଟେଷ୍ଟ.ଭାରତ',
      'විශ්ව-සම්මුති-පිරික්සුම.ලංකා',
      'பொது-ஏற்பு-சோதனை.சிங்கப்பூர்',
      'యూనివర్సల్-ఆమోదం-పరీక్ష.భారత్',
      'ยูเอทดสอบ.ไทย',
      '普遍适用测试.我爱你',
      '普遍適用測試.台灣',
      'ሁለንአቀፍ-ተቀባይነት-ሙከራ.com',
      'ការសាកល្បងទទួលយកជាអន្តរជាតិ.com',
      'အလုံးစုံလက်ခံမှုစမ်းသပ်ချက်.com',
      'ދުނިޔެ-ގަބޫލުކުރާ-ޓެސްޓު.com',
      'universal-acceptance-test.קום',
      'épreuve-acceptation-universelle.org',
      'ཡོངས་ཁྱབ་ངོས་ལེན་བརྟག་དཔྱད.com',
    ]

    funky_domains.each do |domain|
      it "extracts the mention @info@#{domain}" do
        text = "@info@#{domain}"
        extracted = described_class.extract_mentions_or_lists_with_indices(text)
        expect(extracted).to eq [
          { screen_name: "info@#{domain}", indices: [0, text.length] },
        ]
      end
    end
  end

  describe 'extract_hashtags_with_indices' do
    it 'returns an empty array if it does not have # or ＃' do
      text = 'a string without hash sign'
      extracted = described_class.extract_hashtags_with_indices(text)
      expect(extracted).to eq []
    end

    it 'returns hashtags preceded by an ASCII hash' do
      text = 'hello #world'
      extracted = described_class.extract_hashtags_with_indices(text)
      expect(extracted).to eq [{ hashtag: 'world', indices: [6, 12] }]
    end

    it 'returns hashtags preceded by a full-width hash' do
      text = 'hello ＃world'
      extracted = described_class.extract_hashtags_with_indices(text)
      expect(extracted).to eq [{ hashtag: 'world', indices: [6, 12] }]
    end

    it 'does not exclude normal hash text before ://' do
      text = '#hashtag://'
      extracted = described_class.extract_hashtags_with_indices(text)
      expect(extracted).to eq [{ hashtag: 'hashtag', indices: [0, 8] }]
    end

    it 'excludes http://' do
      text = '#hashtaghttp://'
      extracted = described_class.extract_hashtags_with_indices(text)
      expect(extracted).to eq [{ hashtag: 'hashtag', indices: [0, 8] }]
    end

    it 'excludes https://' do
      text = '#hashtaghttps://'
      extracted = described_class.extract_hashtags_with_indices(text)
      expect(extracted).to eq [{ hashtag: 'hashtag', indices: [0, 8] }]
    end

    it 'yields hashtags if a block is given' do
      text = '#hashtag'
      described_class.extract_hashtags_with_indices(text) do |hashtag, start_position, end_position|
        expect(hashtag).to eq 'hashtag'
        expect(start_position).to eq 0
        expect(end_position).to eq 8
      end
    end
  end

  describe 'extract_entities_with_indices' do
    it 'returns empty array when cashtag present' do
      text = '$cashtag'
      extracted = described_class.extract_entities_with_indices(text)
      expect(extracted).to eq []
    end
  end

  describe 'extract_xmpp_uris_with_indices' do
    it 'returns an empty array when the text contains no xmpp: scheme' do
      expect(described_class.extract_xmpp_uris_with_indices('no xmpp here')).to eq []
    end

    it 'extracts a stand-alone user@host URI' do
      expect(described_class.extract_xmpp_uris_with_indices('xmpp:user@example.com')).to eq [
        { url: 'xmpp:user@example.com', indices: [0, 21] },
      ]
    end

    it 'extracts a URI with a resource path' do
      text = 'reach me at xmpp:arnt@example.com/desktop today'
      expect(described_class.extract_xmpp_uris_with_indices(text)).to eq [
        { url: 'xmpp:arnt@example.com/desktop', indices: [12, 41] },
      ]
    end

    it 'extracts a URI with Unicode in localpart, host, and resource' do
      text = 'xmpp:grå@grå.org/grønn/blå'
      expect(described_class.extract_xmpp_uris_with_indices(text)).to eq [
        { url: 'xmpp:grå@grå.org/grønn/blå', indices: [0, 26] },
      ]
    end

    it 'extracts a URI with a query string' do
      expect(described_class.extract_xmpp_uris_with_indices('please join xmpp:muc@example.com?join right now')).to eq [
        { url: 'xmpp:muc@example.com?join', indices: [12, 37] },
      ]
    end

    it 'trims a trailing period' do
      expect(described_class.extract_xmpp_uris_with_indices('see xmpp:user@example.com.')).to eq [
        { url: 'xmpp:user@example.com', indices: [4, 25] },
      ]
    end

    it 'trims trailing comma, semicolon and bracket' do
      expect(described_class.extract_xmpp_uris_with_indices('(xmpp:user@example.com),')).to eq [
        { url: 'xmpp:user@example.com', indices: [1, 22] },
      ]
    end

    it 'requires either an @ or a . after the scheme' do
      expect(described_class.extract_xmpp_uris_with_indices('xmpp:foo bar')).to eq []
    end

    it 'rejects a bare scheme with nothing following' do
      expect(described_class.extract_xmpp_uris_with_indices('plain xmpp: nothing here')).to eq []
    end

    it 'does not match xmpp: in the middle of a word' do
      expect(described_class.extract_xmpp_uris_with_indices('fooxmpp:user@example.com')).to eq []
    end

    it 'returns an empty array for nil input' do
      expect(described_class.extract_xmpp_uris_with_indices(nil)).to eq []
    end
  end

  describe 'extract_magnet_uris_with_indices' do
    it 'returns an empty array when the text contains no magnet:? scheme' do
      expect(described_class.extract_magnet_uris_with_indices('no magnet here')).to eq []
    end

    it 'extracts a minimal magnet URI with just xt' do
      expect(described_class.extract_magnet_uris_with_indices('magnet:?xt=urn:btih:abc')).to eq [
        { url: 'magnet:?xt=urn:btih:abc', indices: [0, 23] },
      ]
    end

    it 'extracts a fully populated magnet URI (xt, dn, xl, tr, as)' do
      url  = 'magnet:?xt=urn:btih:c12fe1c06bba254a9dc9f519b335aa7c1367a88a' \
             '&dn=Big+Buck+Bunny&xl=12345&tr=udp%3A%2F%2Ftracker.example.com%3A80' \
             '&as=http%3A%2F%2Fexample.com%2Ffile'
      text = "see #{url} here"
      expect(described_class.extract_magnet_uris_with_indices(text)).to eq [
        { url: url, indices: [4, 4 + url.length] },
      ]
    end

    it 'rejects a magnet URI that does not contain xt=' do
      expect(described_class.extract_magnet_uris_with_indices('magnet:?as=http%3A%2F%2Fexample.com%2Ffile')).to eq []
    end

    it 'rejects a bare magnet: with no query' do
      expect(described_class.extract_magnet_uris_with_indices('plain magnet: nothing here')).to eq []
    end

    it 'trims a trailing period' do
      expect(described_class.extract_magnet_uris_with_indices('see magnet:?xt=urn:btih:abc.')).to eq [
        { url: 'magnet:?xt=urn:btih:abc', indices: [4, 27] },
      ]
    end

    it 'does not match magnet: in the middle of a word' do
      expect(described_class.extract_magnet_uris_with_indices('foomagnet:?xt=urn:btih:abc')).to eq []
    end

    it 'returns an empty array for nil input' do
      expect(described_class.extract_magnet_uris_with_indices(nil)).to eq []
    end
  end
end
