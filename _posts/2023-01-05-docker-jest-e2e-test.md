---
layout: single
title: "Docker上でjest + Selenium + Headless ChromeでE2Eテストを実現する"
categories: output
tags: smalruby
toc: false
last_modified_at: 2023-01-05T23:15:05+0900
---

スモウルビーの開発を Docker 上で行うようにしましたが、その結果 integration テストが失敗するようになっていました。今回、それを解消することができたのでここに記録を残しておきます。

{% include advertisements.html %}

最近では仕事で Docker (docker-compose) を使うことがほとんどで、その便利さからスモウルビーの開発も Docker 上で行うようにしました。

- [Smalruby 3 Development Environment](https://github.com/smalruby/smalruby3-develop)

実は、Docker に移行したときにミスをしていました。

手元でのテストは unit までしかしておらず、Selenium を使った E2E のテスト integration は実行していませんでした。Circle CI にパスしていたので問題ないと決めつけてしまっていました。

しかし、というかやはりというか、今回、スモウルビーの開発を再開にするにあたって問題が発覚しました。integration のテストが失敗するんですよね。これは Docker 上でのみ発生します。確認は重要ですね。

原因は、 integration テストで利用するためのウェブブラウザがセットアップできていないことでした。何も設定していないので当然ですね。考慮漏れでした。

### 対策1: 同じコンテナにウェブブラウザをインストールする (未完)

そこで、同じコンテナにウェブブラウザをセットアップするためにいろいろ試しました。

- Circle CI の Docker イメージ (cimg/node:14.20-browsers) を使ってみる
- puppeteer のドキュメントに従って google-chrome-standalone をインストールしてみる
- jest から google-chrome-standalone を起動するときのパラメーターを変更してみる

しかし、私にはできませんでした。原因の調べ方がわからなかったのが大きいです。ウェブブラウザが起動しなかった以上の情報が得られませんでした。 jest や Node.js から Selenium を使う方法をよくわかっていないのがまずかったですね。

また、 jest の公式ドキュメント「[puppeteer を使用する](https://jestjs.io/ja/docs/next/puppeteer)」 を読む限り、 [puppeteer](https://github.com/puppeteer/puppeteer) を使うと良さそうでしたが、自動テストの多くは Scratch のものなので変更点が多すぎて採用できませんでした。

### 対策2: 別コンテナにウェブブラウザをインストールする (不採用)

そこで、 `Ruby on Rails` の開発でよく採用されている別コンテナで Selenium と Chrome を起動する方法を試すことにしました。これなら勝手がよくわかっているのでなんとかなりそうです。

- [【Rails5\.2 Selenium】Docker 環境下でのRSpec のSystem test実行方法](https://osusublog.net/?p=1432)
- [【Rails6】Docker環境でRSpecのシステムスペックを実行する](https://qiita.com/masarashi/items/84761a4e8de494f4d073)

まず docker-compose.yml に以下の設定を追加します。

```yaml
  chrome:
    image: selenium/standalone-chrome:latest
    environment:
      - START_XVFB=false
    shm_size: 2gb
    ports:
      - 4444:4444
```

さらに docker-compose.yml に以下の設定を追加して、環境変数で Selenium と Chrome を操作するURLをスモウルビーに伝えます。

```yaml
services:
  gui:
    build: gui
    environment:
      (省略)
      - SELENIUM_REMOTE_URL=http://chrome:4444/wd/hub
```

ポートの 4444 は設定しているので理解できたのですが、`/wd/hub` はなぜそのパスを指定するのかこのときはまだわかりませんした。

あとは、これを jest のテストで扱えばOKなはず。

[smalruby3-gui/test/helpers/selenium-helper.js:59行付近](https://github.com/smalruby/smalruby3-gui/blob/9ccb6fc92eb8065df83608cc753dadc2bc2247c2/test/helpers/selenium-helper.js#L59) で Selenium の設定をしています。環境変数 `SELENIUM_REMOTE_URL` が設定されていれば、自動的にそれを使ってリモートの Chrome を使うようになっているとのこと。素晴らしい！

```javascript
import webdriver from 'selenium-webdriver';
// 省略
class SeleniumHelper {
    constructor () {
        // 省略
    }
    // 省略
    getDriver () {
        const chromeCapabilities = webdriver.Capabilities.chrome();
        const args = [];
        // 省略
        this.driver = new webdriver.Builder()
            // .usingServer(process.env.SELENIUM_REMOTE_URL) は不要
            .forBrowser('chrome')
            .withCapabilities(chromeCapabilities)
            .build();
        return this.driver;
    }
```

これでリモートのChromeを使うことができるようになりました。

しかしながら、それでもテストに失敗してしまいます。

実は integration のテストはローカルのブラウザでローカルのファイルにアクセスすることを前提にしていたのです。そのため、ブラウザが開くURLは `file://~` を指定していました。

[smalruby3-gui/test/helpers/selenium-helper.js:141行目](https://github.com/smalruby/smalruby3-gui/blob/9ccb6fc92eb8065df83608cc753dadc2bc2247c2/test/helpers/selenium-helper.js#L141)

```javascript
        return this.driver
            .get(`file://${uri}`) // ここでローカルのファイルにアクセスしている
            .then(() => (
                this.driver.executeScript('window.onbeforeunload = undefined;')
            ))
```

これではだめですね。

以下のように修正して、

```javascript
        return this.driver
            .get(`http://gui:8061${uri}`)
            .then(() => (
                this.driver.executeScript('window.onbeforeunload = undefined;')
            ))
```

さらにテストのコード [smalruby3-gui/test/integration/ruby-tab.test.js:20行目](https://github.com/smalruby/smalruby3-gui/blob/9ccb6fc92eb8065df83608cc753dadc2bc2247c2/test/integration/ruby-tab.test.js#L20) を修正して、

```javascript
const uri = '/';
```

`uri` をローカルのファイルへの絶対パスではなく `/` に変更すると、期待通りに動作して、テストが成功することを確認できました。

ただ、この変更は面倒すぎます。

- CircleCIと手元でテスト内容を変えないといけない
- 手元で自動テストを実行する前にDevサーバーを起動しておかないといけない
- さらにそのDevサーバーは、リモートのChromeからguiという名前でアクセスできないといけない
  - ので、同じタイミングで起動したり、 docker-compose exec gui で自動テストを実行しないといけない

jest と比べると Ruby on Rails は、これらをすべてフレームワーク側で用意してくれているのは本当にありがたいことだなと思いました。

### 対策3: 同じコンテナにウェブブラウザをインストールする v2 (採用！)

さて、これからどうするか。

リモートのChromeならば期待通りに動作したので、やはりここはローカルのChromeで再度チャレンジしてみようと思います。仕組みは理解できたし、動作確認のやり方も増えたのでなんとかなるはず。

- - -

[Running Puppeteer in Docker](https://github.com/puppeteer/puppeteer/blob/main/docs/troubleshooting.md#running-puppeteer-in-docker) を参考にして、Dockerfileに設定を追加します。

[smalruby3\-develop/gui/Dockerfile](https://github.com/smalruby/smalruby3-develop/blob/main/gui/Dockerfile)

```Dockerfile
RUN set -eux \
    && apt update \
    && apt install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt update \
    && apt install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*
```

注意点としては、google-chrome-stable を Docker イメージにインストールした状態で、環境変数 DETECT_CHROMEDRIVER_VERSION を true にして smalruby3-gui の npm install を実行することです。

```Dockerfile
ENV DETECT_CHROMEDRIVER_VERSION true
```

こうすると、適切な chromedriver がインストールされます。npm install を先に実行してしまうと、google-chrome-stable とのバージョンのミスマッチが発生して、正しく動作しません。

この状態で、google-chrome-stable に適切なオプションを指定して、 `file:///app/gui/smalruby3-gui/build/index.html` にアクセスしてみます。オプションは 「[Seleniumでよく使うChromeOptionsまとめ](https://boardtechlog.com/2020/08/programming/seleniumchrome%E3%81%A7%E3%82%88%E3%81%8F%E4%BD%BF%E3%81%86chromeoptions%E3%81%BE%E3%81%A8%E3%82%81/)」を参考にしました。

```
# google-chrome-stable --headless --no-sandbox --disable-setuid-sandbox --disable-gpu --disable-dev-shm-usage --disable-extensions --use-fake-ui-for-media-stream=deny --autoplay-policy=no-user-gesture-required file:///app/gui/smalruby3-gui/build/index.html
[0105/084535.261668:ERROR:bus.cc(399)] Failed to connect to the bus: Failed to connect to socket /var/run/dbus/system_bus_socket: No such file or directory
[0105/084535.262802:ERROR:bus.cc(399)] Failed to connect to the bus: Failed to connect to socket /var/run/dbus/system_bus_socket: No such file or directory
[0105/084535.268792:WARNING:bluez_dbus_manager.cc(247)] Floss manager not present, cannot set Floss enable/disable.
[0105/084535.280952:WARNING:sandbox_linux.cc(380)] InitializeSandbox() called with multiple threads in process gpu-process.
[0105/084537.223678:WARNING:audio_manager_linux.cc(60)] Falling back to ALSA for audio output. PulseAudio is not available or could not be initialized.
[0105/084537.281428:ERROR:gl_utils.cc(319)] [.WebGL-0x3f3c0a2fbf00]GL Driver Message (OpenGL, Performance, GL_CLOSE_PATH_NV, High): GPU stall due to ReadPixels
[0105/084537.446800:ERROR:gl_utils.cc(319)] [.WebGL-0x3f3c0a2fbf00]GL Driver Message (OpenGL, Performance, GL_CLOSE_PATH_NV, High): GPU stall due to ReadPixels
[0105/084537.469693:ERROR:gl_utils.cc(319)] [.WebGL-0x3f3c0a2fbf00]GL Driver Message (OpenGL, Performance, GL_CLOSE_PATH_NV, High): GPU stall due to ReadPixels
```

エラーはたくさん出ていますがこれでOKです。NGなときは最後に `Abnormal renderer termination.` と出ます。

つぎに自動テストと同じ内容を、Node.jsの [REPL](https://ja.wikipedia.org/wiki/REPL) を使って試します。

```
# node
```

で Node.js の REPL を起動して、

```javascript
require ('chromedriver');
const webdriver = require ('selenium-webdriver');
const chromeCapabilities = webdriver.Capabilities.chrome();
const args = [];
args.push('--headless');
args.push('--no-sandbox');
args.push('--disable-gpu');
args.push('--disable-dev-shm-usage');
args.push('--disable-extensions');
args.push('--use-fake-ui-for-media-stream=deny');
args.push('--autoplay-policy=no-user-gesture-required');
chromeCapabilities.set('chromeOptions', {args});
chromeCapabilities.setLoggingPrefs({
    performance: 'ALL'
});
const driver = new webdriver.Builder().forBrowser('chrome').withCapabilities(chromeCapabilities).build();
driver.get('file:///app/gui/smalruby3-gui/build/index.html').then(() => { console.log('OK'); });
```

と打ち込んでから少し待つと無事に `OK` と出ました。なるほどね。chromedriver のバージョンの違いが原因で期待通りに動作していなかったようです。

これに合わせて jest の設定も変更しました。すると jest も正しく動作しました。
具体的な変更内容は
[test: run integration test on docker \#323](https://github.com/smalruby/smalruby3-gui/pull/323/files)
のPRで確認できます。

なお、 `--disable-dev-shm-usage` を設定しないと動作が不安定でした。オプションの付替えを何時間も試してようやくたどり着きました。

最後に、Dockerの設定変更も行って作業完了です。

- [build\(gui\): install chrome for integration test](https://github.com/smalruby/smalruby3-develop/commit/2f37bca1d4491f57a460c2f671d2a6b8a6cb70d8)

- - -

まとめます。

- スモウルビーの開発を Docker 上で行うようにしましたが、その結果 integration テストが失敗するようになっていました
- 別コンテナでchromeを動かして integration テストが成功するようになったのですが、別の問題があるためこれは採用しませんでした
- Dockerにchromeをインストールして、chromeにオプションを適切に設定することで integration テストが成功するようになりました

途中、何度も諦めようかと思いましたが、無事作業が完了できてよかったです。

また、今回の作業を通じて、あらためて Ruby on Rails のすごさを思い知らされました。E2Eの自動テストを実行するまでの準備がこれほど面倒だとは思ってもみませんでした。すごい Rails！
