---
layout: single
title: ZOOMとLINEのグループ通話をつないでビデオ会議を行う
description: "ZOOM と LINE の音声を BlackHole でつなぎ、LINE のグループ通話に参加するだけで ZOOM のビデオ会議にも参加できるようにしてみました"
lang: ja_JP
header:
  overlay_image: /assets/images/video-meeting-with-zoom-and-line-group/zoom-and-line-summary.png
  overlay_filter: 0.4
  caption: "ZOOMとLINEのグループ通話をつなぐ"
tagline: "ビデオ会議への参加者を増やすためのトライ"
categories: output
tags: zoom line
toc: false
last_modified_at: 2024-11-04T03:12:53+0000
---

PTA役員がきっかけで青少年育成に携わるようになって約13年。いまでは地域の青少年育成に関わる人を増やしたり、育成するための活動をさせてもらっています。人生、何がきっかけで、どんなことをするのかなんて、わかんないものですね。

その青少年育成の活動において、ZOOMを利用したビデオ会議の参加者が少ないという悩みがあります。もしかするとZOOMの敷居が高いのかもしれない、とのご意見をいただき、試しにLINEのグループ通話でもZOOMのビデオ会議に参加できるようにしてみました。

{% include advertisements.html %}

試したのはこんな感じ。

![ZOOMとLINEのグループ通話をつなぐ](/assets/images/video-meeting-with-zoom-and-line-group/zoom-and-line-summary.png)

まずは手元のコンピューター (MacBook Air M3) に ZOOM と LINE を用意します。そして、 ZOOM と LINE の音声を [BlackHole](https://existential.audio/blackhole/) というソフトウェアを使ってつなぎます。さらに LINE のグループでビデオ通話を開始して、ZOOM の画面を共有します。これで ZOOM と LINE をつなぐことができます。

つぎにiPhoneのZOOMで接続して準備完了です。私はこちらをつかって参加者とやりとりをします。

参加者は、ZOOMまたはLINEの好きな方で接続します。

![LINEで接続する](/assets/images/video-meeting-with-zoom-and-line-group/SS_2024-11-04T13.48.13_fix.png)

ただし、LINEの場合は音声は問題ないのですが、画面についてはZOOMの画面しか表示されないため、自分の顔が相手からは見えません。これは、この仕組みの制限になります。

## ZOOM と LINE の音声をつなぐ

今回使った [BlackHole](https://existential.audio/blackhole/) の設定について、詳しく説明します。

BlackHole は仮想オーディオデバイスといわれるソフトウェアで、あるソフトウェア(例えば ZOOM) のスピーカーとマイクを別のソフトウェア (例えば LINE) で使えるようにします。
BlackHole には 2ch用、16ch用、64ch用があります。今回は 2ch用を使いました。

インストールは [Homebrew](https://brew.sh/ja/) で行いました。途中で sudo のためにログインパスワードを入力する必要がありました。

```
brew install blackhole-2ch
```

インストール後、ZOOM と LINE の設定画面で、マイクとスピーカーをそれぞれ BlackHole 2ch に設定します。

ZOOM の設定
![ZOOMの設定](/assets/images/video-meeting-with-zoom-and-line-group/SS_2024-11-04T13.43.24_fix.png)

LINEの設定
![LINEの設定(1)](/assets/images/video-meeting-with-zoom-and-line-group/SS_2024-11-04T13.45.35_fix.png)
![LINEの設定(2)](/assets/images/video-meeting-with-zoom-and-line-group/SS_2024-11-04T13.45.52_fix.png)
![LINEの設定(3)](/assets/images/video-meeting-with-zoom-and-line-group/SS_2024-11-04T13.45.59_fix.png)

これで、ZOOM と LINE の音声をつなぐことができます。

## LINE でも参加できるようになりましたが...

LINE で簡単に参加できるようになったのですが、実際に LINE で参加されたのは2名でした。全体でも5名の参加者だったのでまぁ、そんなものだろうなとは思いますが、もっと参加してもらえるようにしたいと思うので、これからもなにかしらのトライを続けたい考えています。
