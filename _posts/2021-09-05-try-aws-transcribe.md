---
layout: single
title:  "AWS Transcribeを試す！"
header:
  overlay_image: /assets/images/try-aws-transcribe/aws-transcribe.png
  overlay_filter: 0.4
tagline: "LINEの音声メッセージから文字起こしをしたいのです"
categories: diary
tags:
last_modified_at: 2021-09-05T16:16:30:31+0900
---
[LINE Messaging API](https://developers.line.biz/ja/docs/messaging-api/overview/)、夢が広がります。LINEで通知するだけでなく、やりとりしたテキスト、動画、音声をアプリケーションでダウンロードして扱うことができます。

ただ、音声そのままだと「あの〜」とか無音とかが多くて使いにくい。
そこで、LINEで録音した音声メッセージから文字起こしをするため [Amazon Transcribe]() を試してみた。

{% include advertisements.html %}

基本的には [Amazon Transcribe を使用して音声を文字起こしする方法 | AWS](https://aws.amazon.com/jp/getting-started/hands-on/create-audio-transcript-transcribe/) の通りです。
さらに aws-cli だと [Amazon Transcribeで音声の文字起こしを行う。 - Qiita](https://qiita.com/kooohei/items/2580addd6c1bbc8f1c34) が詳しい。

UIが最近変わったみたいでそれなりに **つまずきポイント** があった。
- ダウンロードしたファイルの名前を `transcribe-sample.5fc2109bb28268d10fbc677e64b7e59256783d3c.mp3` から `transcribe-sample.mp3` に変える
- 東京リージョンでOK
  - [Amazon Transcribe がアジアパシフィック (東京) リージョンで利用可能に](https://aws.amazon.com/jp/about-aws/whats-new/2019/11/amazon-transcribe-available-in-asia-pacific-region/) 
- バケット名は `trnsrb-test-20210905` とした
  - バケット名は一意じゃないといけない。適当なsuffixをつけること
- アップロードしたファイルのURLはファイル名をクリックして表示された詳細画面から行える。チェックボックスはない。
  - s3://trnsrb-test-20210905/transcribe-sample.mp3

あと、アナウンサーとかPro PodCaster ではない素人、しかも中学生の音声認識はだいぶ難しいことがわかった。テキストはあきらめて音声でやりとりしよう。空白を消したり、1.2倍速にしたりすることでストレスを少なくしよう。

- - -

余談です。

ブログを書くときにタイトルとURLのセットが必要になるんだけど、URLはともかくタイトルのコピーが面倒。
そこで、 Chrome 拡張 [a01sa01to / TitleAndURL_Picker](https://github.com/a01sa01to/titleAndURL_Picker) です。
この手のものは変なことをされるといやなのでソースコードも公開されていて、さらに [その解説](https://qiita.com/a01sa01to/items/bd7b18b4ec3dc6c46b32) まであるのはありがたい。
すごく便利なのでみなさんも使ったらいいと思います。
