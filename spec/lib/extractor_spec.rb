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

    context 'with IDN domains' do
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
      ]
      broken_funky_domain = [
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

      broken_funky_domain.each do |domain|
        it "does not extract the mention @info@#{domain}" do
          text = "@info@#{domain}"
          extracted = described_class.extract_mentions_or_lists_with_indices(text)
          expect(extracted).to_not eq [
            { screen_name: "info@#{domain}", indices: [0, text.length] },
          ]
        end
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
end
