# Bootsnap [![Build Status](https://travis-ci.org/Shopify/bootsnap.svg?branch=master)](https://travis-ci.org/Shopify/bootsnap)

Bootsnap は RubyVM におけるバイトコード生成やファイルルックアップ等の時間のかかる処理を最適化するためのライブラリです。ActiveSupport や YAML もサポートしています。

注意書き: このライブラリは英語話者によって管理されています。この README は日本語ですが、日本語でのサポートはしておらず、リクエストにお答えすることもできません。バイリンガルの方がサポートをサポートしてくださる場合はお知らせください！:)

## パフォーマンス

Discourse では、約6秒から3秒まで、約50%の起動時間短縮が確認されています。小さなアプリケーションでも、50%の改善（3.6秒から1.8秒）が確認されています。非常に巨大でモノリシックなアプリである Shopify のプラットフォームでは、約25秒から6.5秒へと約75％短縮されました。

## 使用方法

この gem は MacOS と Linux で作動します。まずは、`bootsnap` を `Gemfile` に追加します:

```ruby
gem 'bootsnap', require: false
```

Rails を使用している場合は、以下のコードを、`config/boot.rb` 内にある `require 'bundler/setup'` の後に追加してください。

```ruby
require 'bootsnap/setup'
```

Rails を使用していない場合、または、より多くの設定を変更したい場合は、以下のコードを `require 'bundler/setup'` の直後に追加してください(早く読み込まれるほど、より多くのものを最適化することができます）。

```ruby
require 'bootsnap'
env = ENV['RAILS_ENV'] || "development"
Bootsnap.setup(
  cache_dir:            'tmp/cache',          # キャッシュファイルを保存する path
  development_mode:     env == 'development', # 現在の作業環境、例えば RACK_ENV, RAILS_ENV など。
  load_path_cache:      true,                 # キャッシュで LOAD_PATH を最適化する。
  autoload_paths_cache: true,                 # キャッシュで ActiveSupport による autoload を行う。
  disable_trace:        true,                 # (アルファ) `RubyVM::InstructionSequence.compile_option = { trace_instruction: false }`をセットする。
  compile_cache_iseq:   true,                 # ISeq キャッシュをコンパイルする
  compile_cache_yaml:   true                  # YAML キャッシュをコンパイルする
)
```

ヒント: `require 'bootsnap'` を `BootLib::Require.from_gem('bootsnap', 'bootsnap')` で、 [こちらのトリック](https://github.com/Shopify/bootsnap/wiki/Bootlib::Require)を使って置き換えることができます。こうすると、巨大な`$LOAD_PATH`がある場合でも、起動時間を最短化するのに役立ちます。

## Bootsnap の内部動作

Bootsnap は、処理に時間のかかるメソッドの結果をキャッシュすることで最適化しています。これには、大きく分けて2つのカテゴリに分けられます。

* [Path Pre-Scanning](#path-pre-scanning)
    *  `Kernel#require` と `Kernel#load` を `$LOAD_PATH` のフルスキャンを行わないようにオーバーライドします。
    *  `ActiveSupport::Dependencies.{autoloadable_module?,load_missing_constant,depend_on}` を `ActiveSupport::Dependencies.autoload_paths` のフルスキャンを行わないようにオーバーライドします。
* [Compilation caching](#compilation-caching)
    *  Ruby バイトコードのコンパイル結果をキャッシュするためのメソッド `RubyVM::InstructionSequence.load_iseq` が実装されています。
    *  `YAML.load_file` を YAML オブジェクトのロード結果を MessagePack でキャッシュするようにオーバーライドします。 MessagePack でサポートされていないタイプが使われている場合は Marshal が使われます。

### Path Pre-Scanning

_(このライブラリは [bootscale](https://github.com/byroot/bootscale) という別のライブラリを元に開発されました)_

Bootsnap の始動時、あるいはパス(例えば、`$LOAD_PATH`)の変更時に、`Bootsnap::LoadPathCache` がキャッシュから必要なエントリーのリストを読み込みます。または、必要に応じてフルスキャンを実行し結果をキャッシュします。
その後、たとえば `require 'foo'` を評価する場合, Ruby は `$LOAD_PATH` `['x', 'y', ...]` のすべてのエントリーを繰り返し評価することで `x/foo.rb`, `y/foo.rb` などを探索します。これに対して Bootsnap は、キャッシュされた reuiqre 可能なファイルと `$LOAD_PATH` を見ることで、Rubyが最終的に選択するであろうパスで置き換えます。

この動作によって生成された syscall を見ると、最終的な結果は以前なら次のようになります。

```
open  x/foo.rb # (fail)
# (imagine this with 500 $LOAD_PATH entries instead of two)
open  y/foo.rb # (success)
close y/foo.rb
open  y/foo.rb
...
```

これが、次のようになります:

```
open y/foo.rb
...
```

`autoload_paths_cache` オプションが `Bootsnap.setup` に与えられている場合、`ActiveSupport::Dependencies.autoload_paths` をトラバースするメソッドにはまったく同じ最適化が使用されます。

`*_path_cache` 機能を埋め込むオーバーライドを図にすると、次のようになります。

![Bootsnapの説明図](https://cloud.githubusercontent.com/assets/3074765/24532120/eed94e64-158b-11e7-9137-438d759b2ac8.png)

Bootsnap は、 `$LOAD_PATH` エントリを安定エントリと不安定エントリの2つのカテゴリに分類します。不安定エントリはアプリケーションが起動するたびにスキャンされ、そのキャッシュは30秒間だけ有効になります。安定エントリーに期限切れはありません。コンテンツがスキャンされると、決して変更されないものとみなされます。

安定していると考えられる唯一のディレクトリは、Rubyのインストールプレフィックス (`RbConfig::CONFIG['prefix']`, または `/usr/local/ruby` や `~/.rubies/x.y.z`)下にあるものと、`Gem.path` (たとえば　`~/.gem/ruby/x.y.z`) や `Bundler.bundle_path` 下にあるものです。他のすべては不安定エントリと分類されます。

[`Bootsnap::LoadPathCache::Cache`](https://github.com/Shopify/bootsnap/blob/master/lib/bootsnap/load_path_cache/cache.rb) に加えて次の図では、エントリの解決がどのように機能するかを理解するのに役立つかもしれません。経路探索は以下のようになります。

![パス探索の仕組み](https://cloud.githubusercontent.com/assets/3074765/25388270/670b5652-299b-11e7-87fb-975647f68981.png)

また、`LoadError` のスキャンがどれほど重いかに注意を払うことも大切です。もし Ruby が `require 'something'` を評価し、そのファイルが `$LOAD_PATH` にない場合は、それを知るために `2 * $LOAD_PATH.length` のファイルシステムアスセスが必要になります。Bootsnap は、ファイルシステムにまったく触れずに `LoadError` を投げ、この結果をキャッシュします。

## Compilation Caching

このコンセプトのより分かりやすい解説は [yomikomu](https://github.com/ko1/yomikomu) をお読み下さい。

Ruby には複雑な文法が実装されており、構文解析は簡単なオペレーションではありません。1.9以降、Ruby は Ruby ソースを内部のバイトコードに変換した後、Ruby VM によって実行してきました。2.3.0 以降、[RubyはAPIを公開し](https://ruby-doc.org/core-2.3.0/RubyVM/InstructionSequence.html)、そのバイトコードをキャッシュすることができるようになりました。これにより、同じファイルが複数ロードされた時の、比較的時間のかかる部分をバイパスすることができます。

また、Shopify のアプリケーションでは、アプリケーションの起動時に YAML ドキュメントの読み込みに多くの時間を費やしていることを発見しました。そして、 MessagePack と Marshal は deserialization にあたって YAML よりもはるかに高速であるということに気付きました。そこで、YAML ドキュメントを、Ruby バイトコードと同じコンパイルキャッシングの最適化を施すことで、高速化しています。Ruby の "バイトコード" フォーマットに相当するものは MessagePack ドキュメント (あるいは、MessagePack をサポートしていないタイプの YAML ドキュメントの場合は、Marshal stream)になります。

これらのコンパイル結果は、入力ファイル（FNV1a-64）のフルパスのハッシュを取って生成されたファイル名で、キャッシュディレクトリに保存されます。

Bootsnap 無しでは、ファイルを `require` するために生成された syscall の順序は次のようになっていました:

```
open    /c/foo.rb -> m
fstat64 m
close   m
open    /c/foo.rb -> o
fstat64 o
fstat64 o
read    o
read    o
...
close   o
```

しかし Bootsnap では、次のようになります:

```
open      /c/foo.rb -> n
fstat64   n
close     n
open      /c/foo.rb -> n
fstat64   n
open      (cache) -> m
read      m
read      m
close     m
close     n
```

これは一目見るだけでは劣化していると思われるかもしれませんが、性能に大きな違いがあります。

（両方のリストの最初の3つの syscalls -- `open`, `fstat64`, `close` -- は本質的に有用ではありません。[このRubyパッチ](https://bugs.ruby-lang.org/issues/13378)は、Boosnap と組み合わせることによって、それらを最適化しています）

Bootsnap は、64バイトのヘッダーとそれに続くキャッシュの内容を含んだキャッシュファイルを書き込みます。ヘッダーは、次のいくつかのフィールドで構成されるキャッシュキーです。

- `version`、Bootsnapにハードコードされる基本的なスキーマのバージョン
- `os_version`、(macOS, BSDの) 現在のカーネルバージョンか 、(Linuxの) glibc のバージョンのハッシュ
- `compile_option`、`RubyVM::InstructionSequence.compile_option` の返り値
- `ruby_revision`、コンパイルされたRubyのバージョン
- `size`、ソースファイルのサイズ
- `mtime`、コンパイル時のソースファイルの最終変更タイムスタンプ
- `data_size`、バッファに読み込む必要のあるヘッダーに続くバイト数。

キーが有効な場合、キャッシュがファイルからロードされます。そうでない場合、キャッシュは再生成され、現在のキャッシュを破棄します。

# 最終的なキャッシュ結果

次のファイル構造があるとします。

```
/
├── a
├── b
└── c
    └── foo.rb
```

そして、このような `$LOAD_PATH` があるとします。

```
["/a", "/b", "/c"]
```

Bootsnap なしで `require 'foo'` を呼び出すと、Ruby は次の順序で syscalls を生成します:

```
open    /a/foo.rb -> -1
open    /b/foo.rb -> -1
open    /c/foo.rb -> n
close   n
open    /c/foo.rb -> m
fstat64 m
close   m
open    /c/foo.rb -> o
fstat64 o
fstat64 o
read    o
read    o
...
close   o
```

しかし Bootsnap では、次のようになります:

```
open      /c/foo.rb -> n
fstat64   n
close     n
open      /c/foo.rb -> n
fstat64   n
open      (cache) -> m
read      m
read      m
close     m
close     n
```

Bootsnap なしで `require 'nope'` を呼び出すと、次のようになります:

```
open    /a/nope.rb -> -1
open    /b/nope.rb -> -1
open    /c/nope.rb -> -1
open    /a/nope.bundle -> -1
open    /b/nope.bundle -> -1
open    /c/nope.bundle -> -1
```

...そして、Bootsnap で `require 'nope'` を呼び出すと、次のようになります...

```
# (nothing!)
```
