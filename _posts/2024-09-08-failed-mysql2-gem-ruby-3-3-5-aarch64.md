---
layout: single
title: "mysql2-0.5.6 gemのインストールに失敗したらLIBRARY_PATHにzstdを追加すること"
categories: output
tags: ruby rails
toc: false
last_modified_at: 2024-09-08T15:00:00+0900
---

Rails の Dev Container を試そうとしていきなりつまずきました。mysql2-0.5.6 gem がインストールできなかったのです。しかしながら、zstd ライブラリのパスを環境変数 LIBRARY_PATH に追加することで無事インストールできました。

```bash
LIBRARY_PATH="${HOMEBREW_PREFIX}/lib:$LIBRARY_PATH" gem install mysql2
```

### 環境

- Apple M3 (MacBook Air 13 2024)
- macOS Sonoma 14.6.1
- [Homebrew](https://brew.sh/ja/)
- ruby 3.3.5
  - [anyenv](https://github.com/anyenv/anyenv) で [rbenv](https://github.com/rbenv/rbenv) をインストール
  - ruby 3.3.5 を global に設定済み ( `rbenv global 3.3.5` )
- rails 7.2.1 gem
  - `gem install rails`
- mysql 9.0.1
  - `brew install mysql`
- zstd 1.5.6
  - `brew install zstd`
- **mysql2 0.5.6 gem ← ここで失敗**
  - `gem install mysql2`

### 作業の記録

rails 7.2.1 gem のインストールに続いて、mysql2 gem のインストールを行ったところ、以下のように失敗した。

```bash
$ gem install mysql2
Building native extensions. This could take a while...
ERROR:  Error installing mysql2:
        ERROR: Failed to build gem native extension.

    current directory: /Users/kouji/.anyenv/envs/rbenv/versions/3.3.5/lib/ruby/gems/3.3.0/gems/mysql2-0.5.6/ext/mysql2
/Users/kouji/.anyenv/envs/rbenv/versions/3.3.5/bin/ruby extconf.rb
checking for rb_absint_size()... yes
checking for rb_absint_singlebit_p()... yes
checking for rb_gc_mark_movable()... yes
checking for rb_wait_for_single_fd()... yes
checking for rb_enc_interned_str() in ruby.h... yes
-----
Using --with-openssl-dir=/opt/homebrew/opt/openssl@3
-----
-----
Using mysql_config at /opt/homebrew/bin/mysql_config
-----
checking for mysql.h... yes
checking for errmsg.h... yes
checking for SSL_MODE_DISABLED in mysql.h... yes
checking for SSL_MODE_PREFERRED in mysql.h... yes
checking for SSL_MODE_REQUIRED in mysql.h... yes
checking for SSL_MODE_VERIFY_CA in mysql.h... yes
checking for SSL_MODE_VERIFY_IDENTITY in mysql.h... yes
checking for MYSQL.net.vio in mysql.h... yes
checking for MYSQL.net.pvio in mysql.h... no
checking for MYSQL_DEFAULT_AUTH in mysql.h... yes
checking for MYSQL_ENABLE_CLEARTEXT_PLUGIN in mysql.h... yes
checking for SERVER_QUERY_NO_GOOD_INDEX_USED in mysql.h... yes
checking for SERVER_QUERY_NO_INDEX_USED in mysql.h... yes
checking for SERVER_QUERY_WAS_SLOW in mysql.h... yes
checking for MYSQL_OPTION_MULTI_STATEMENTS_ON in mysql.h... yes
checking for MYSQL_OPTION_MULTI_STATEMENTS_OFF in mysql.h... yes
checking for my_bool in mysql.h... no
checking for mysql_ssl_set() in mysql.h... no
-----
Don't know how to set rpath on your system, if MySQL libraries are not in path mysql2 may not load
-----
-----
Setting libpath to /opt/homebrew/Cellar/mysql/9.0.1_1/lib
-----
creating Makefile

current directory: /Users/kouji/.anyenv/envs/rbenv/versions/3.3.5/lib/ruby/gems/3.3.0/gems/mysql2-0.5.6/ext/mysql2
make DESTDIR\= sitearchdir\=./.gem.20240908-69354-4ptxnv sitelibdir\=./.gem.20240908-69354-4ptxnv clean

current directory: /Users/kouji/.anyenv/envs/rbenv/versions/3.3.5/lib/ruby/gems/3.3.0/gems/mysql2-0.5.6/ext/mysql2
make DESTDIR\= sitearchdir\=./.gem.20240908-69354-4ptxnv sitelibdir\=./.gem.20240908-69354-4ptxnv
compiling client.c
In file included from client.c:15:
./mysql_enc_name_to_ruby.h:43:1: warning: a function definition without a prototype is deprecated in all versions of C and is not supported in C2x [-Wdeprecated-non-prototype]
mysql2_mysql_enc_name_to_rb_hash (str, len)
^
./mysql_enc_name_to_ruby.h:86:1: warning: a function definition without a prototype is deprecated in all versions of C and is not supported in C2x [-Wdeprecated-non-prototype]
mysql2_mysql_enc_name_to_rb (str, len)
^
2 warnings generated.
compiling infile.c
compiling mysql2_ext.c
compiling result.c
result.c:304:35: warning: implicit conversion loses integer precision: 'unsigned long' to 'int' [-Wshorten-64-to-32]
        precision = field->length - (field->decimals > 0 ? 2 : 1);
                  ~ ~~~~~~~~~~~~~~^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1 warning generated.
compiling statement.c
linking shared-object mysql2/mysql2.bundle
ld: library 'zstd' not found
clang: error: linker command failed with exit code 1 (use -v to see invocation)
make: *** [mysql2.bundle] Error 1

make failed, exit code 2

Gem files will remain installed in /Users/kouji/.anyenv/envs/rbenv/versions/3.3.5/lib/ruby/gems/3.3.0/gems/mysql2-0.5.6 for inspection.
Results logged to /Users/kouji/.anyenv/envs/rbenv/versions/3.3.5/lib/ruby/gems/3.3.0/extensions/arm64-darwin-23/3.3.0/mysql2-0.5.6/gem_make.out
```

`ld: library 'zstd' not found` から zstd ライブラリが見つからないことが原因だと推測。LD に失敗する場合はさらに関連ライブラリが見つからないこともあるので、この時点ではまだ zstd が原因だと確定していなかった。

zstd はインストール済み。関連ライブラリも問題ない ([otool -L で調べられる](https://qiita.com/Lewuathe/items/c31edcc9303708cefe3e))。

```text
$ brew search zstd
==> Formulae
zstd ✔                                                                                                   zsxd

$ ls /opt/homebrew/lib/libzstd.*
/opt/homebrew/lib/libzstd.1.5.6.dylib   /opt/homebrew/lib/libzstd.1.dylib       /opt/homebrew/lib/libzstd.a             /opt/homebrew/lib/libzstd.dylib

$ otool -L /opt/homebrew/lib/libzstd.1.5.6.dylib
/opt/homebrew/lib/libzstd.1.5.6.dylib:
        /opt/homebrew/opt/zstd/lib/libzstd.1.dylib (compatibility version 1.0.0, current version 1.5.6)
        /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1345.100.2)
```

これでエラーの原因はリンカーのパスに `libzstd.*` が含まれていないことだとほぼ確定。そもそも Homebrew でインストールしたライブラリのパスを追加していなかったらしい。失敗、失敗。

```bash
# HOMEBREW_PREFIX=/opt/homebrew
LIBRARY_PATH="${HOMEBREW_PREFIX}/lib:$LIBRARY_PATH" gem install mysql2
```

ついでに .zshrc に以下を追加しておく。これで問題ないんだけど、環境変数 HOMEBREW_PREFIX はどのタイミングで設定されているのかしら。

```zsh
export LIBRARY_PATH="${HOMEBREW_PREFIX}/lib:$LIBRARY_PATH"
```

無事、解決。

### 協力者の募集

[スモウルビー](https://smalruby.app) ([GitHub](https://github.com/smalruby/smalruby3-develop)) の開発にご協力いただける方を常に募集しています。

ご協力いただける方は、 contact@smalruby.jp までご連絡いただいてもいいですし、連絡なしで「xxx のブロックに対応しました」というPRを作成してもらってもかまいません。むしろその方が好都合です。[スポンサーも募集しています](https://github.com/sponsors/smalruby)。

また、 [拙著:小学生から楽しむ きらきらRubyプログラミング](https://amzn.to/3SLNXrk) をご購入いただけるとありがたいです。スモウルビーの使い方と教え方を学ぶことができる書籍です。特に小・中学校の先生に読んでいただきたいです。
<img src="https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL320_.jpg" srcset="https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL320_.jpg 1x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL480_FMwebp_QL65_.jpg 1.5x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL640_FMwebp_QL65_.jpg 2x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL800_FMwebp_QL65_.jpg 2.5x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL960_FMwebp_QL65_.jpg 3x" alt="小学生から楽しむ きらきらRubyプログラミング">

日本中の小・中学生が学校の授業や地域のプログラミング教室でスモウルビーを使っています。みなさんのご協力で、たくさんの子どもたちがハッピーになります。ご協力、よろしくお願いします。
