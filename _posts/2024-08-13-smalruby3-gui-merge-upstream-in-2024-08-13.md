---
layout: single
title: "smalruby3-guiをupstream の変更内容をマージしたい (が、まだできず…)"
categories: output
tags: smalruby
toc: true
last_modified_at: 2024-08-13T19:30:00:00+0900
---

scratch-gui を元に開発している smalruby3-gui にupstream の修正を取り込もうとしていますが、スモウルビーの起動時にエラーが発生して思うように進められていません。

備忘録を兼ねて、途中経過を記録しておきます。

---

もう何年もスモウルビーという Scratch のブロックと Ruby スクリプトを相互変換できるプログラミング学習環境を開発・運用しています。
<https://smalruby.app>

レポジトリは [smalruby3-gui ](https://github.com/smalruby/smalruby3-gui) です。Scratch Foundationが開発している [scratch-gui](https://scratchfoundation/scratch-gui) をベースにして、Scratch のブロックとRuby スクリプトを相互変換できる機能を追加しています。オープンソースソフトウェアなので、誰でも自由に開発や再配布ができます。

定期的に最新の変更内容を upstream から取り込んでいます。基本的な手順は [こちら](https://github.com/smalruby/smalruby3-gui/wiki/merge_scratch-gui_develop)にまとめています。

いつもならすぐに終わる作業なのですが、今回はエラーの対応に手間取っていて、2024/08/13現在、まだ終わっていません。

ここまで手間取っているのは、

 - Circle CIからGitHub Actionsへの移行
 - node.js のバージョンアップにともない、Dockerfile の更新が必要だった
 - ↑により、npm run build に失敗する

ということがあったためです。今ようやくスモウルビーが起動でき、エラーが発生することがわかって、さて困ったな、という状況です。

エラーは以下のもの。

```text
invariant.js:42 Uncaught Invariant Violation: Element type is invalid: expected a string (for built-in components) or a class/function (for composite components) but got: symbol.

Check the render method of `SBFileUploaderComponent`.
    at invariant (http://localhost:8601/gui.js:293886:15)
    at createFiberFromElementType (http://localhost:8601/gui.js:353733:5)
    at createFiberFromElement (http://localhost:8601/gui.js:353678:15)
    at reconcileSingleElement (http://localhost:8601/gui.js:354926:19)
    at reconcileChildFibers (http://localhost:8601/gui.js:355025:35)
    at reconcileChildrenAtPriority (http://localhost:8601/gui.js:355675:30)
    at reconcileChildren (http://localhost:8601/gui.js:355666:5)
    at finishClassComponent (http://localhost:8601/gui.js:355802:5)
    at updateClassComponent (http://localhost:8601/gui.js:355774:12)
    at beginWork (http://localhost:8601/gui.js:356153:16)
invariant	@	invariant.js:42
createFiberFromElementType	@	react-dom.development.js:8185
createFiberFromElement	@	react-dom.development.js:8130
reconcileSingleElement	@	react-dom.development.js:9378
reconcileChildFibers	@	react-dom.development.js:9477
reconcileChildrenAtPriority	@	react-dom.development.js:10127
reconcileChildren	@	react-dom.development.js:10118
finishClassComponent	@	react-dom.development.js:10254
updateClassComponent	@	react-dom.development.js:10226
beginWork	@	react-dom.development.js:10605
performUnitOfWork	@	react-dom.development.js:12573
workLoop	@	react-dom.development.js:12682
callCallback	@	react-dom.development.js:1299
invokeGuardedCallbackDev	@	react-dom.development.js:1338
invokeGuardedCallback	@	react-dom.development.js:1195
performWork	@	react-dom.development.js:12800
scheduleUpdateImpl	@	react-dom.development.js:13185
scheduleUpdate	@	react-dom.development.js:13124
scheduleTopLevelUpdate	@	react-dom.development.js:13395
updateContainer	@	react-dom.development.js:13425
（匿名）	@	react-dom.development.js:17105
unbatchedUpdates	@	react-dom.development.js:13256
renderSubtreeIntoContainer	@	react-dom.development.js:17104
render	@	react-dom.development.js:17129
__WEBPACK_DEFAULT_EXPORT__	@	render-gui.jsx:60
./src/playground/index.jsx	@	index.jsx:23
__webpack_require__	@	bootstrap:22
（匿名）	@	startup:6
（匿名）	@	startup:6
webpackUniversalModuleDefinition	@	universalModuleDefinition:9
（匿名）	@	universalModuleDefinition:10

The above error occurred in the <SBFileUploaderComponent> component:
    in SBFileUploaderComponent (created by Connect(SBFileUploaderComponent))
    in Connect(SBFileUploaderComponent) (created by InjectIntl(Connect(SBFileUploaderComponent)))
    in InjectIntl(Connect(SBFileUploaderComponent)) (created by VMManager)
    in VMManager (created by Connect(VMManager))
    in Connect(VMManager) (created by VMListener)
    in VMListener (created by Connect(VMListener))
    in Connect(VMListener) (created by ProjectSaverComponent)
    in ProjectSaverComponent (created by Connect(ProjectSaverComponent))
    in Connect(ProjectSaverComponent) (created by TitledComponent)
    in TitledComponent (created by Connect(TitledComponent))
    in Connect(TitledComponent) (created by InjectIntl(Connect(TitledComponent)))
    in InjectIntl(Connect(TitledComponent)) (created by ProjectFetcherComponent)
    in ProjectFetcherComponent (created by Connect(ProjectFetcherComponent))
    in Connect(ProjectFetcherComponent) (created by InjectIntl(Connect(ProjectFetcherComponent)))
    in InjectIntl(Connect(ProjectFetcherComponent)) (created by QueryParserComponent)
    in QueryParserComponent (created by Connect(QueryParserComponent))
    in Connect(QueryParserComponent) (created by FontLoaderComponent)
    in FontLoaderComponent (created by Connect(FontLoaderComponent))
    in Connect(FontLoaderComponent) (created by ErrorBoundaryWrapper)
    in ErrorBoundary (created by Connect(ErrorBoundary))
    in Connect(ErrorBoundary) (created by ErrorBoundaryWrapper)
    in ErrorBoundaryWrapper (created by LocalizationWrapper)
    in IntlProvider (created by Connect(IntlProvider))
    in Connect(IntlProvider) (created by LocalizationWrapper)
    in LocalizationWrapper (created by Connect(LocalizationWrapper))
    in Connect(LocalizationWrapper) (created by HashParserComponent)
    in HashParserComponent (created by Connect(HashParserComponent))
    in Connect(HashParserComponent) (created by AppStateWrapper)
    in IntlProvider (created by Connect(IntlProvider))
    in Connect(IntlProvider) (created by AppStateWrapper)
    in Provider (created by AppStateWrapper)
    in AppStateWrapper
```

バックトレースを見ても原因を特定できませんでした。
また、元の scratch-gui は問題なく起動したので、原因は smalruby3-gui にあるのは間違いありません。

エラーが出なくなるところまで、smalruby3-gui で行った変更を少しずつ削っていこうと考えています。

デバッグに使っているのは、

 - VS Code
 - react-dev-tools (Chrome拡張)
 - redux-dev-tools (Chrome拡張)

です。
scratch-gui によっていずれの拡張機能も使える状態なのがありがたい。

いまのところ、以下は問題ないようです。

 - opal の読み込み (opal を読み込むと for ~ in が不正な動作をする可能性があるが、特に問題ないようだ)
 - Rubyタブ
 - Webpack の設定変更 (PWAの設定追加は問題ない)

さてさて、どうしたものだか。地道にやっていくしかないんかな...。

### 協力者の募集

スモウルビーの開発にご協力いただける方を常に募集しています。

ご協力いただける方は、 contact@smalruby.jp までご連絡いただいてもいいですし、連絡なしで「xxx のブロックに対応しました」というPRを作成してもらってもかまいません。むしろその方が好都合です。

日本中の小・中学生が学校の授業や地域のプログラミング教室でスモウルビーを使っています。みなさんのご協力で、たくさんの子どもたちがハッピーになります。ご協力、よろしくお願いします。
