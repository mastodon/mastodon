## 環境で使用するドメインリスト

以下のような場合、ドメインを変更することがあります。
- データベースを初期化する場合
- データ補正に手間がかかると判断した場合
- アカウントをすべて消す場合

## ドメインの運用

- ドメインは `mstdn-stg-*.delta-t.work` の形式で表現します(`*`は任意の英数小文字)
- まだ運用されていないドメインは DNS解決ができません
- 運用中のドメインは1つのみ稼働しています
- 運用を終えたドメインは `410 Gone` のステータスコードを返します

- destory表示になったドメインは以後使用されません
  - インスタンス内でフォローされた場合はpurgeかドメインブロックを実施して下さい

## 下記リストの記載

| 表記 | 状態 |
:---:|----
|destroy|運用を終了しています。`410 Gone` か DNS解決エラー になります。|
|**running**|現在サービスを提供中です。|
|(なし)|今後使用される予定のドメイン名です。DNS解決エラー になります。|
|soon|今後使用される予定のドメイン名ですが、`404 Not Found` になります。|

## ドメインのリスト

| ドメイン名 | 状態 | 更新日 | 備考 |
----|:--:|:--:|----
|mstdn-stg-aatrox.delta-t.work|soon|2018/03/13|DNS設定済み|
|mstdn-stg-ahri.delta-t.work||||
|mstdn-stg-akali.delta-t.work||||
|mstdn-stg-alistar.delta-t.work||||
|mstdn-stg-amumu.delta-t.work||||
|mstdn-stg-anivia.delta-t.work||||
|mstdn-stg-annie.delta-t.work||||
|mstdn-stg-ashe.delta-t.work||||
|mstdn-stg-aurelionsol.delta-t.work||||
|mstdn-stg-azir.delta-t.work||||
|mstdn-stg-bard.delta-t.work||||
|mstdn-stg-blitzcrank.delta-t.work||||
|mstdn-stg-brand.delta-t.work||||
|mstdn-stg-braum.delta-t.work||||
|mstdn-stg-caitlyn.delta-t.work||||
|mstdn-stg-camille.delta-t.work||||
|mstdn-stg-cassiopeia.delta-t.work||||
|mstdn-stg-chogath.delta-t.work||||
|mstdn-stg-corki.delta-t.work||||
|mstdn-stg-darius.delta-t.work||||
|mstdn-stg-diana.delta-t.work||||
|mstdn-stg-drmundo.delta-t.work||||
|mstdn-stg-draven.delta-t.work||||
|mstdn-stg-ekko.delta-t.work||||
|mstdn-stg-elise.delta-t.work||||
|mstdn-stg-evelynn.delta-t.work||||
|mstdn-stg-ezreal.delta-t.work||||
|mstdn-stg-fiddlesticks.delta-t.work||||
|mstdn-stg-fiora.delta-t.work||||
|mstdn-stg-fizz.delta-t.work||||
|mstdn-stg-galio.delta-t.work||||
|mstdn-stg-gangplank.delta-t.work||||
|mstdn-stg-garen.delta-t.work||||
|mstdn-stg-gnar.delta-t.work||||
|mstdn-stg-gragas.delta-t.work||||
|mstdn-stg-graves.delta-t.work||||
|mstdn-stg-hecarim.delta-t.work||||
|mstdn-stg-heimerdinger.delta-t.work||||
|mstdn-stg-illaoi.delta-t.work||||
|mstdn-stg-irelia.delta-t.work||||
|mstdn-stg-ivern.delta-t.work||||
|mstdn-stg-janna.delta-t.work||||
|mstdn-stg-jarvaniv.delta-t.work||||
|mstdn-stg-jax.delta-t.work||||
|mstdn-stg-jayce.delta-t.work||||
|mstdn-stg-jhin.delta-t.work||||
|mstdn-stg-jinx.delta-t.work||||
|mstdn-stg-kaisa.delta-t.work||||
|mstdn-stg-kalista.delta-t.work||||
|mstdn-stg-karma.delta-t.work||||
|mstdn-stg-karthus.delta-t.work||||
|mstdn-stg-kassadin.delta-t.work||||
|mstdn-stg-katarina.delta-t.work||||
|mstdn-stg-kayle.delta-t.work||||
|mstdn-stg-kayn.delta-t.work||||
|mstdn-stg-kennen.delta-t.work||||
|mstdn-stg-khazix.delta-t.work||||
|mstdn-stg-kindred.delta-t.work||||
|mstdn-stg-kled.delta-t.work||||
|mstdn-stg-kogmaw.delta-t.work||||
|mstdn-stg-leblanc.delta-t.work||||
|mstdn-stg-leesin.delta-t.work||||
|mstdn-stg-leona.delta-t.work||||
|mstdn-stg-lissandra.delta-t.work||||
|mstdn-stg-lucian.delta-t.work||||
|mstdn-stg-lulu.delta-t.work||||
|mstdn-stg-lux.delta-t.work||||
|mstdn-stg-malphite.delta-t.work||||
|mstdn-stg-malzahar.delta-t.work||||
|mstdn-stg-maokai.delta-t.work||||
|mstdn-stg-masteryi.delta-t.work||||
|mstdn-stg-missfortune.delta-t.work||||
|mstdn-stg-mordekaiser.delta-t.work||||
|mstdn-stg-morgana.delta-t.work||||
|mstdn-stg-nami.delta-t.work||||
|mstdn-stg-nasus.delta-t.work||||
|mstdn-stg-nautilus.delta-t.work||||
|mstdn-stg-neeko.delta-t.work||||
|mstdn-stg-nidalee.delta-t.work||||
|mstdn-stg-nocturne.delta-t.work||
|mstdn-stg-nunuwillump.delta-t.work||
|mstdn-stg-olaf.delta-t.work||
|mstdn-stg-orianna.delta-t.work||
|mstdn-stg-ornn.delta-t.work||
|mstdn-stg-pantheon.delta-t.work||
|mstdn-stg-poppy.delta-t.work||
|mstdn-stg-pyke.delta-t.work||
|mstdn-stg-quinn.delta-t.work||
|mstdn-stg-rakan.delta-t.work||
|mstdn-stg-rammus.delta-t.work||
|mstdn-stg-reksai.delta-t.work||
|mstdn-stg-renekton.delta-t.work||
|mstdn-stg-rengar.delta-t.work||
|mstdn-stg-riven.delta-t.work||
|mstdn-stg-rumble.delta-t.work||
|mstdn-stg-ryze.delta-t.work||
|mstdn-stg-sejuani.delta-t.work||
|mstdn-stg-shaco.delta-t.work||
|mstdn-stg-shen.delta-t.work||
|mstdn-stg-shyvana.delta-t.work||
|mstdn-stg-singed.delta-t.work||
|mstdn-stg-sion.delta-t.work||
|mstdn-stg-sivir.delta-t.work||
|mstdn-stg-skarner.delta-t.work||
|mstdn-stg-sona.delta-t.work||
|mstdn-stg-soraka.delta-t.work||
|mstdn-stg-swain.delta-t.work||
|mstdn-stg-sylas.delta-t.work||
|mstdn-stg-syndra.delta-t.work||
|mstdn-stg-tahmkench.delta-t.work||
|mstdn-stg-taliyah.delta-t.work||
|mstdn-stg-talon.delta-t.work||
|mstdn-stg-taric.delta-t.work||
|mstdn-stg-teemo.delta-t.work||
|mstdn-stg-thresh.delta-t.work||
|mstdn-stg-tristana.delta-t.work||
|mstdn-stg-trundle.delta-t.work||
|mstdn-stg-tryndamere.delta-t.work||
|mstdn-stg-twistedfate.delta-t.work||
|mstdn-stg-twitch.delta-t.work||
|mstdn-stg-udyr.delta-t.work||
|mstdn-stg-urgot.delta-t.work||
|mstdn-stg-varus.delta-t.work||
|mstdn-stg-vayne.delta-t.work||
|mstdn-stg-veigar.delta-t.work||
|mstdn-stg-velkoz.delta-t.work||
|mstdn-stg-vi.delta-t.work||
|mstdn-stg-viktor.delta-t.work||
|mstdn-stg-vladimir.delta-t.work||
|mstdn-stg-volibear.delta-t.work||
|mstdn-stg-warwick.delta-t.work||
|mstdn-stg-wukong.delta-t.work||
|mstdn-stg-xayah.delta-t.work||
|mstdn-stg-xerath.delta-t.work||
|mstdn-stg-xinzhao.delta-t.work||
|mstdn-stg-yasuo.delta-t.work||
|mstdn-stg-yorick.delta-t.work||
|mstdn-stg-zac.delta-t.work||
|mstdn-stg-zed.delta-t.work||
|mstdn-stg-ziggs.delta-t.work||
|mstdn-stg-zilean.delta-t.work||
|mstdn-stg-zoe.delta-t.work||
|mstdn-stg-zyra.delta-t.work||
|
