---
layout: single
title: "Apple Silicon上でR2P2をビルドしてみたが、ダメだった"
categories: output
tags: picoruby
toc: true
last_modified_at: 2024-09-08T23:00:00+0900
---

Xで以下の投稿を見かけたので、R2P2のビルドを試してみたがダメだった、という内容です。

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">求む協力者：R2P2のmasterがお手元でビルドできるか（特にmacOS）、ラズパイピコでハングアップせずに動くか（特にirb）追試をお願いしたい！（パーサがPrismになっているよ...!!!!）<a href="https://t.co/XkiELQptlI">https://t.co/XkiELQptlI</a></p>&mdash; Making a New mruby-compiler 🇺🇦 (@hasumikin) <a href="https://twitter.com/hasumikin/status/1832709869662880020?ref_src=twsrc%5Etfw">September 8, 2024</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

### 環境

- Apple M3 (MacBook Air 13 2024)
- macOS Sonoma 14.6.1
- ruby 3.3.5
  - [anyenv](https://github.com/anyenv/anyenv) で [rbenv](https://github.com/rbenv/rbenv) をインストール
  - ruby 3.3.5 を global に設定済み ( `rbenv global 3.3.5` )

### rake setupまで

[picoruby/R2P2](https://github.com/picoruby/R2P2/) の手順に従ってビルドする。

```bash
brew install --cask gcc-arm-embedded
# (ファイルが大きいのか通信速度が遅いのか、ダウンロードにしばらく時間がかかる)

mkdir -p ~/work/picoruby
cd ~/work/picoruby

git clone https://github.com/picoruby/R2P2.git
cd R2P2

ruby -v
# (以下、実行結果)
# ruby 3.3.5 (2024-09-03 revision ef084cc8f4) [arm64-darwin23]

rake setup
# (以下、実行結果)
# git submodule update --init
# Submodule 'lib/picoruby' (git@github.com:picoruby/picoruby.git) registered for path 'lib/picoruby'
# Cloning into '/Users/kouji/work/picoruby/R2P2/lib/picoruby'...
# The authenticity of host 'github.com (20.27.177.113)' can't be established.
# ED25519 key fingerprint is SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU.
# This key is not known by any other names.
# Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
# (ここで yes を入力)
# Warning: Permanently added 'github.com' (ED25519) to the list of known hosts.
# git@github.com: Permission denied (publickey).
# fatal: Could not read from remote repository.
#
# Please make sure you have the correct access rights
# and the repository exists.
# fatal: clone of 'git@github.com:picoruby/picoruby.git' into submodule path '/Users/kouji/work/picoruby/R2P2/lib/picoruby' failed
# Failed to clone 'lib/picoruby'. Retry scheduled
# Cloning into '/Users/kouji/work/picoruby/R2P2/lib/picoruby'...
# git@github.com: Permission denied (publickey).
# fatal: Could not read from remote repository.
#
# Please make sure you have the correct access rights
# and the repository exists.
# fatal: clone of 'git@github.com:picoruby/picoruby.git' into submodule path '/Users/kouji/work/picoruby/R2P2/lib/picoruby' failed
# Failed to clone 'lib/picoruby' a second time, aborting
# rake aborted!
# Command failed with status (1): [git submodule update --init]
# /Users/kouji/work/picoruby/R2P2/Rakefile:46:in `block in <top (required)>'
# Tasks: TOP => setup
# (See full trace by running task with --trace)
```

エラー。GitHub に SSH の公開鍵を登録していないため、 `git@github.com` ではレポジトリを clone できないため。

[GitHub アカウントへの新しい SSH キーの追加](https://docs.github.com/ja/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) を参考にして、 SSH の鍵ペアを作成して、 GitHub に公開鍵を登録。

```bash
mkdir -p ~/.ssh/
ssh-keygen -t ed25519 -C "kouji.takao@gmail.com" -f ~/.ssh/id_github

pbcopy < ~/.ssh/id_github.pub
# ログイン後、プロフィール / Settings / SSH and GPG keys の New SSH key から登録。名前はマシン名にした。

eval "$(ssh-agent -s)"
touch ~/.ssh/config
cat >> ~/.ssh/config
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_github

# control+D
```

再度、 rake setup。ここまでは問題ない。

```bash
rake setup
# (以下、実行結果)
# git submodule update --init
# Cloning into '/Users/kouji/work/picoruby/R2P2/lib/picoruby'...
# Submodule path 'lib/picoruby': checked out '1f00486a481ca256a6c8cb21152e45a58113e494'
# bundle install
# Bundler 2.5.18 is running, but your lockfile was generated with 2.3.26. Installing Bundler 2.3.26 and restarting using that version.
# Fetching gem metadata from https://rubygems.org/.
# Fetching bundler 2.3.26
# (省略)
# Installing guard 2.18.1
# Installing steep 1.6.0
# Bundle complete! 6 Gemfile dependencies, 47 gems now installed.
# Use `bundle info [gemname]` to see where a bundled gem is installed.
```

### rake

続いて rake。

```bash
rake
# (以下、実行結果)
# rake test
# GIT   https://github.com/picoruby/mruby-compiler2.git -> build/repos/host/mruby-compiler2
# Cloning into '/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2'...
# remote: Enumerating objects: 115, done.
# (省略)
# HEAD is now at 8fd092f Merge pull request #215 from hasumikin/allow-null-for-mrbc_raw_free
# Skipped steep check as WIP
# Cleaned up target build folder
# AR    build/host/lib/libmruby_core.a
# ar: no archive members specified
# usage:  ar -d [-TLsv] archive file ...
#         ar -m [-TLsv] archive file ...
#         ar -m [-abiTLsv] position archive file ...
#         ar -p [-TLsv] archive [file ...]
#         ar -q [-cTLsv] archive file ...
#         ar -r [-cuTLsv] archive file ...
#         ar -r [-abciuTLsv] position archive file ...
#         ar -t [-TLsv] archive [file ...]
#         ar -x [-ouTLsv] archive [file ...]
# rake aborted!
# Command failed with status (1): [ar rs "/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/host/lib/libmruby_core.a" ]
# /Users/kouji/work/picoruby/R2P2/lib/picoruby/lib/mruby/build/command.rb:37:in `_run'
# /Users/kouji/work/picoruby/R2P2/lib/picoruby/lib/mruby/build/command.rb:238:in `run'
# /Users/kouji/work/picoruby/R2P2/lib/picoruby/tasks/libmruby.rake:3:in `block (2 levels) in <top (required)>'
# /Users/kouji/work/picoruby/R2P2/lib/picoruby/Rakefile:44:in `block in <top (required)>'
# /Users/kouji/work/picoruby/R2P2/lib/picoruby/Rakefile:125:in `block in <top (required)>'
# Tasks: TOP => build => /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/host/lib/libmruby_core.a
# (See full trace by running task with --trace)
# rake aborted!
# Command failed with status (1): [rake test]
# /Users/kouji/work/picoruby/R2P2/Rakefile:64:in `block (2 levels) in <top (required)>'
# /Users/kouji/work/picoruby/R2P2/Rakefile:63:in `block in <top (required)>'
# Tasks: TOP => default => all => libmruby
# (See full trace by running task with --trace)
```

エラーメッセージから推測すると、GNU の ar コマンドを期待しているようなのでインストールする。

```bash
brew install binutils
echo 'export PATH="/opt/homebrew/opt/binutils/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

rake
# (以下、実行結果)
# rake test
# GIT CHECKOUT DETACH /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2 -> ba9dea0b23672c12a4f266f912eaef694c1dbde4
# HEAD is now at ba9dea0 Fix many bugs
# Skipped steep check as WIP
# Cleaned up target build folder
# AR    build/host/lib/libmruby_core.a
# ar: creating /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/host/lib/libmruby_core.a
# (省略)
# /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen_prism.inc:2377:11: error: expected expression
#           mrc_node *parent = ((pm_constant_path_node_t *)cpath)->parent;
#           ^
# fatal error: too many errors emitted, stopping now [-ferror-limit=]
# 6 warnings and 20 errors generated.
# rake aborted!
# (省略)
```

これで ar の問題は解決。たくさんエラーがでているけども...。

### pico-sdkとpico-extrasのclone

pico-sdk を用意していなかったので、このタイミングで用意する。

```bash
cd ~/work/picoruby
git clone https://github.com/raspberrypi/pico-sdk.git
git clone https://github.com/raspberrypi/pico-extras.git
export PICO_SDK_PATH=`pwd`/pico-sdk
export PICO_EXTRAS_PATH=`pwd`/pico-extras
```

cmakeもインストールしてみる。これは単に最新版に更新されただけだったので、cmakeはインストール済みだったようです。

```bash
brew install cmake
```

### 再度rake。しかしコンパイルエラーが発生

再度、rake。だがコンパイルエラーは解消されず。ということで、今日はここまで。

```text
$ rake
rake test
GIT CHECKOUT DETACH /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2 -> ba9dea0b23672c12a4f266f912eaef694c1dbde4
HEAD is now at ba9dea0 Fix many bugs
Skipped steep check as WIP
Cleaned up target build folder
AR    build/host/lib/libmruby_core.a
ar: creating /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/host/lib/libmruby_core.a
CC    build/repos/host/mruby-compiler2/src/ccontext.c -> build/host/mrbgems/mruby-compiler2/src/ccontext.o
clang: warning: -Wl,--gc-sections: 'linker' input unused [-Wunused-command-line-argument]
clang: warning: argument unused during compilation: '-s' [-Wunused-command-line-argument]
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/ccontext.c:3:
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/../include/mrc_ccontext.h:7:
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include/mrc_pool.h:10:29: warning: redefinition of typedef 'mrc_ccontext' is a C11 feature [-Wtypedef-redefinition]
typedef struct mrc_ccontext mrc_ccontext;
                            ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include/mrc_diagnostic.h:25:29: note: previous definition is here
typedef struct mrc_ccontext mrc_ccontext;
                            ^
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/ccontext.c:3:
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/../include/mrc_ccontext.h:24:36: warning: redefinition of typedef 'mrc_diagnostic_list' is a C11 feature [-Wtypedef-redefinition]
typedef struct mrc_diagnostic_list mrc_diagnostic_list;
                                   ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include/mrc_diagnostic.h:22:3: note: previous definition is here
} mrc_diagnostic_list;
  ^
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/ccontext.c:3:
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/../include/mrc_ccontext.h:25:25: warning: redefinition of typedef 'mrc_pool' is a C11 feature [-Wtypedef-redefinition]
typedef struct mrc_pool mrc_pool;
                        ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include/mrc_pool.h:9:25: note: previous definition is here
typedef struct mrc_pool mrc_pool;
                        ^
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/ccontext.c:3:
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/../include/mrc_ccontext.h:69:3: warning: redefinition of typedef 'mrc_ccontext' is a C11 feature [-Wtypedef-redefinition]
} mrc_ccontext;                 /* compiler context */
  ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include/mrc_pool.h:10:29: note: previous definition is here
typedef struct mrc_ccontext mrc_ccontext;
                            ^
4 warnings generated.
CC    build/repos/host/mruby-compiler2/src/cdump.c -> build/host/mrbgems/mruby-compiler2/src/cdump.o
clang: warning: -Wl,--gc-sections: 'linker' input unused [-Wunused-command-line-argument]
clang: warning: argument unused during compilation: '-s' [-Wunused-command-line-argument]
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/cdump.c:10:
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/../include/mrc_ccontext.h:7:
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include/mrc_pool.h:10:29: warning: redefinition of typedef 'mrc_ccontext' is a C11 feature [-Wtypedef-redefinition]
typedef struct mrc_ccontext mrc_ccontext;
                            ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include/mrc_diagnostic.h:25:29: note: previous definition is here
typedef struct mrc_ccontext mrc_ccontext;
                            ^
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/cdump.c:10:
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/../include/mrc_ccontext.h:24:36: warning: redefinition of typedef 'mrc_diagnostic_list' is a C11 feature [-Wtypedef-redefinition]
typedef struct mrc_diagnostic_list mrc_diagnostic_list;
                                   ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include/mrc_diagnostic.h:22:3: note: previous definition is here
} mrc_diagnostic_list;
  ^
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/cdump.c:10:
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/../include/mrc_ccontext.h:25:25: warning: redefinition of typedef 'mrc_pool' is a C11 feature [-Wtypedef-redefinition]
typedef struct mrc_pool mrc_pool;
                        ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include/mrc_pool.h:9:25: note: previous definition is here
typedef struct mrc_pool mrc_pool;
                        ^
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/cdump.c:10:
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/../include/mrc_ccontext.h:69:3: warning: redefinition of typedef 'mrc_ccontext' is a C11 feature [-Wtypedef-redefinition]
} mrc_ccontext;                 /* compiler context */
  ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include/mrc_pool.h:10:29: note: previous definition is here
typedef struct mrc_ccontext mrc_ccontext;
                            ^
4 warnings generated.
CC    build/repos/host/mruby-compiler2/src/codedump.c -> build/host/mrbgems/mruby-compiler2/src/codedump.o
clang: warning: -Wl,--gc-sections: 'linker' input unused [-Wunused-command-line-argument]
clang: warning: argument unused during compilation: '-s' [-Wunused-command-line-argument]
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codedump.c:4:
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/../include/mrc_ccontext.h:7:
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include/mrc_pool.h:10:29: warning: redefinition of typedef 'mrc_ccontext' is a C11 feature [-Wtypedef-redefinition]
typedef struct mrc_ccontext mrc_ccontext;
                            ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include/mrc_diagnostic.h:25:29: note: previous definition is here
typedef struct mrc_ccontext mrc_ccontext;
                            ^
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codedump.c:4:
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/../include/mrc_ccontext.h:24:36: warning: redefinition of typedef 'mrc_diagnostic_list' is a C11 feature [-Wtypedef-redefinition]
typedef struct mrc_diagnostic_list mrc_diagnostic_list;
                                   ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include/mrc_diagnostic.h:22:3: note: previous definition is here
} mrc_diagnostic_list;
  ^
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codedump.c:4:
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/../include/mrc_ccontext.h:25:25: warning: redefinition of typedef 'mrc_pool' is a C11 feature [-Wtypedef-redefinition]
typedef struct mrc_pool mrc_pool;
                        ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include/mrc_pool.h:9:25: note: previous definition is here
typedef struct mrc_pool mrc_pool;
                        ^
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codedump.c:4:
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/../include/mrc_ccontext.h:69:3: warning: redefinition of typedef 'mrc_ccontext' is a C11 feature [-Wtypedef-redefinition]
} mrc_ccontext;                 /* compiler context */
  ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include/mrc_pool.h:10:29: note: previous definition is here
typedef struct mrc_ccontext mrc_ccontext;
                            ^
4 warnings generated.
CC    build/repos/host/mruby-compiler2/src/codegen.c -> build/host/mrbgems/mruby-compiler2/src/codegen.o
clang: warning: -Wl,--gc-sections: 'linker' input unused [-Wunused-command-line-argument]
clang: warning: argument unused during compilation: '-s' [-Wunused-command-line-argument]
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen.c:4:
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/../include/mrc_irep.h:11:
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include/mrc_ccontext.h:7:
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include/mrc_pool.h:10:29: warning: redefinition of typedef 'mrc_ccontext' is a C11 feature [-Wtypedef-redefinition]
typedef struct mrc_ccontext mrc_ccontext;
                            ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include/mrc_diagnostic.h:25:29: note: previous definition is here
typedef struct mrc_ccontext mrc_ccontext;
                            ^
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen.c:4:
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/../include/mrc_irep.h:11:
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include/mrc_ccontext.h:24:36: warning: redefinition of typedef 'mrc_diagnostic_list' is a C11 feature [-Wtypedef-redefinition]
typedef struct mrc_diagnostic_list mrc_diagnostic_list;
                                   ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include/mrc_diagnostic.h:22:3: note: previous definition is here
} mrc_diagnostic_list;
  ^
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen.c:4:
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/../include/mrc_irep.h:11:
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include/mrc_ccontext.h:25:25: warning: redefinition of typedef 'mrc_pool' is a C11 feature [-Wtypedef-redefinition]
typedef struct mrc_pool mrc_pool;
                        ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include/mrc_pool.h:9:25: note: previous definition is here
typedef struct mrc_pool mrc_pool;
                        ^
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen.c:4:
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/../include/mrc_irep.h:11:
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include/mrc_ccontext.h:69:3: warning: redefinition of typedef 'mrc_ccontext' is a C11 feature [-Wtypedef-redefinition]
} mrc_ccontext;                 /* compiler context */
  ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include/mrc_pool.h:10:29: note: previous definition is here
typedef struct mrc_ccontext mrc_ccontext;
                            ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen.c:31:19: warning: redefinition of typedef 'mrc_int' is a C11 feature [-Wtypedef-redefinition]
  typedef int32_t mrc_int;
                  ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/../include/mrc_common.h:90:19: note: previous definition is here
  typedef int32_t mrc_int;
                  ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen.c:32:20: warning: redefinition of typedef 'mrc_uint' is a C11 feature [-Wtypedef-redefinition]
  typedef uint32_t mrc_uint;
                   ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/../include/mrc_common.h:91:20: note: previous definition is here
  typedef uint32_t mrc_uint;
                   ^
In file included from /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen.c:1771:
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen_prism.inc:1615:11: error: expected expression
          int catch_entry, begin, end;
          ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen_prism.inc:1621:11: error: use of undeclared identifier 'catch_entry'
          catch_entry = catch_handler_new(s);
          ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen_prism.inc:1622:11: error: use of undeclared identifier 'begin'
          begin = s->pc;
          ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen_prism.inc:1626:11: error: use of undeclared identifier 'end'
          end = s->pc;
          ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen_prism.inc:1629:32: error: use of undeclared identifier 'catch_entry'
          catch_handler_set(s, catch_entry, MRC_CATCH_RESCUE, begin, end, s->pc);
                               ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen_prism.inc:1629:63: error: use of undeclared identifier 'begin'
          catch_handler_set(s, catch_entry, MRC_CATCH_RESCUE, begin, end, s->pc);
                                                              ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen_prism.inc:1629:70: error: use of undeclared identifier 'end'
          catch_handler_set(s, catch_entry, MRC_CATCH_RESCUE, begin, end, s->pc);
                                                                     ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen_prism.inc:1690:13: error: expected expression
            pm_buffer_t buf = {0};
            ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen_prism.inc:1691:32: error: use of undeclared identifier 'buf'
            pm_integer_string(&buf, &cast->value);
                               ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen_prism.inc:1692:13: error: use of undeclared identifier 'buf'
            buf.value[buf.length] = '\0';
            ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen_prism.inc:1692:23: error: use of undeclared identifier 'buf'
            buf.value[buf.length] = '\0';
                      ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen_prism.inc:1694:23: error: use of undeclared identifier 'buf'
              memmove(buf.value, buf.value+1, buf.length);
                      ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen_prism.inc:1694:34: error: use of undeclared identifier 'buf'
              memmove(buf.value, buf.value+1, buf.length);
                                 ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen_prism.inc:1694:47: error: use of undeclared identifier 'buf'
              memmove(buf.value, buf.value+1, buf.length);
                                              ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen_prism.inc:1694:23: error: use of undeclared identifier 'buf'
              memmove(buf.value, buf.value+1, buf.length);
                      ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen_prism.inc:1695:15: error: use of undeclared identifier 'buf'
              buf.length--;
              ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen_prism.inc:1697:38: error: use of undeclared identifier 'buf'
            int off = new_litbint(s, buf.value, 10, cast->value.negative);
                                     ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen_prism.inc:1699:29: error: use of undeclared identifier 'buf'
            pm_buffer_free(&buf);
                            ^
/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen_prism.inc:2377:11: error: expected expression
          mrc_node *parent = ((pm_constant_path_node_t *)cpath)->parent;
          ^
fatal error: too many errors emitted, stopping now [-ferror-limit=]
6 warnings and 20 errors generated.
rake aborted!
Command failed with status (1): [clang -MMD -c -std=gnu99 -Wall -Wundef -Werror-implicit-function-declaration -Wwrite-strings -Wzero-length-array -O3 -s -finline-functions -ffunction-sections -fdata-sections -Wl,--gc-sections -DMRB_NO_PRESYM -DDISABLE_MRUBY -DMRBC_USE_MATH=1 -DMRBC_INT64=1 -DMAX_SYMBOLS_COUNT=1000 -DMAX_VM_COUNT=255 -DNDEBUG=1 -DMRBC_USE_HAL_POSIX -DMRBC_ALLOC_LIBC -DREGEX_USE_ALLOC_LIBC -DDISABLE_MRUBY -DPRISM_BUILD_MINIMAL -DMRBGEM_MRUBY_COMPILER2_VERSION=0.0.0 -I"/Users/kouji/work/picoruby/R2P2/lib/picoruby/include" -I"/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/host/mrbgems" -I"/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include" -I"/Users/kouji/work/picoruby/R2P2/lib/picoruby/mrbgems/picoruby-mrubyc/lib/mrubyc/src" -I"/Users/kouji/work/picoruby/R2P2/lib/picoruby/mrbgems/picoruby-mrubyc/lib/mrubyc/hal/posix" -I"/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/lib/prism/include" -I"/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include" -I"/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/lib/prism/include" -I"/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/include" -o "/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/host/mrbgems/mruby-compiler2/src/codegen.o" "/Users/kouji/work/picoruby/R2P2/lib/picoruby/build/repos/host/mruby-compiler2/src/codegen.c"]
/Users/kouji/work/picoruby/R2P2/lib/picoruby/lib/mruby/build/command.rb:37:in `_run'
/Users/kouji/work/picoruby/R2P2/lib/picoruby/lib/mruby/build/command.rb:99:in `run'
/Users/kouji/work/picoruby/R2P2/lib/picoruby/lib/mruby/build/command.rb:120:in `block (2 levels) in define_rules'
/Users/kouji/work/picoruby/R2P2/lib/picoruby/Rakefile:44:in `block in <top (required)>'
/Users/kouji/work/picoruby/R2P2/lib/picoruby/Rakefile:125:in `block in <top (required)>'
Tasks: TOP => build => /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/host/lib/libmruby.a => /Users/kouji/work/picoruby/R2P2/lib/picoruby/build/host/mrbgems/mruby-compiler2/src/codegen.o
(See full trace by running task with --trace)
rake aborted!
Command failed with status (1): [rake test]
/Users/kouji/work/picoruby/R2P2/Rakefile:64:in `block (2 levels) in <top (required)>'
/Users/kouji/work/picoruby/R2P2/Rakefile:63:in `block in <top (required)>'
Tasks: TOP => default => all => libmruby
(See full trace by running task with --trace)
```

### 協力者の募集

[スモウルビー](https://smalruby.app) ([GitHub](https://github.com/smalruby/smalruby3-develop)) の開発にご協力いただける方を常に募集しています。

ご協力いただける方は、 contact@smalruby.jp までご連絡いただいてもいいですし、連絡なしで「xxx のブロックに対応しました」というPRを作成してもらってもかまいません。むしろその方が好都合です。[スポンサーも募集しています](https://github.com/sponsors/smalruby)。

また、 [拙著:小学生から楽しむ きらきらRubyプログラミング](https://amzn.to/3SLNXrk) をご購入いただけるとありがたいです。スモウルビーの使い方と教え方を学ぶことができる書籍です。特に小・中学校の先生に読んでいただきたいです。
<img src="https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL320_.jpg" srcset="https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL320_.jpg 1x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL480_FMwebp_QL65_.jpg 1.5x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL640_FMwebp_QL65_.jpg 2x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL800_FMwebp_QL65_.jpg 2.5x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL960_FMwebp_QL65_.jpg 3x" alt="小学生から楽しむ きらきらRubyプログラミング">

日本中の小・中学生が学校の授業や地域のプログラミング教室でスモウルビーを使っています。みなさんのご協力で、たくさんの子どもたちがハッピーになります。ご協力、よろしくお願いします。
