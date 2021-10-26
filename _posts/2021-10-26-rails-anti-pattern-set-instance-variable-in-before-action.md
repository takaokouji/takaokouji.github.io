---
layout: single
title:  "Railsアンチパターン: コントローラーのbefore_actionでset_xxx (前編)"
categories: output
tags: ruby rails kaigionrails
toc: true
last_modified_at: 2021-10-26T01:01:05:21+0900
---
[Kaigi on Rails 2021](https://kaigionrails.org/2021/) はとてもよかったですね。特に [Keynote by Rafael França - Kaigi on Rails 2021](https://kaigionrails.org/2021/talks/rafaelfranca/) は Ruby や Rails に関わるすべての人に聞いてほしい、本当にすばらしいものでした。2015年の半年間のエピソードは自分と重なる部分があり、共感して目が潤んでしまいました。

後日アーカイブが公開されるとのことなので、ぜひともバズって、たくさんの人に見てもらえるといいですね！

さて、その Kaigi on Rails 2021の中で [before_actionとのつらくならない付き合い方 #kaigionrails / how to using "before_action" with happy in Rails - Speaker Deck](https://speakerdeck.com/shinkufencer/how-to-using-before-action-with-happy-in-rails) という発表がありました。
<iframe class="speakerdeck-iframe" frameborder="0" src="https://speakerdeck.com/player/a819db96f4fb4fc687162ebc7160eb2d" title="before_actionとのつらくならない付き合い方 #kaigionrails / how to using &quot;before_action&quot;  with happy in Rails" allowfullscreen="true" mozallowfullscreen="true" webkitallowfullscreen="true" style="border: 0px; background: padding-box padding-box rgba(0, 0, 0, 0.1); margin: 0px; padding: 0px; border-radius: 6px; box-shadow: rgba(0, 0, 0, 0.2) 0px 5px 40px; width: 560px; height: 314px;"></iframe>

この発表がきっかけとなって Rails 本体の修正案を考えたので、そのことについて書きます。

{% include advertisements.html %}

## コントローラーのbefore_action :set_xxxはアンチパターン

発表の内容を簡単に説明すると、
scaffold でコントローラーを生成します。そこには以下のように before_action で `set_xxx` を呼び出し、インスタンス変数にモデルのインスタンスを格納するためのコードが書かれています。

```ruby
class MessagesController < ApplicationController
  before_action :set_message, only: %i[ show edit update destroy ] 
  
  # (省略)

  # GET /messages/1
  def show
  end

  # (省略)
  
  # PATCH/PUT /messages/1
  def update
    if @message.update("message_params")
      redirect_to @message, notice: "Message was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # (省略)

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end
    
    # (省略)
```

でも、これは良くないやり方 (アンチパターン) です。だから別のやり方にしましょう。
そのやり方は (...とても良い内容なのですがここでは省略...) です。

というのが発表の内容でした。

たしかにそうなんですよね。たくさんの記事もあります。異論はまったくありません。

- [Rails の before_action :set_* って必要？ - ネットの海の片隅で](https://osa.hatenablog.com/entry/good-bye-before-action-setter)
- [Controllerのbefore_actionにおける インスタンス変数セットについて](https://www.slideshare.net/pospome/controllerbeforeaction)
- [Removing the @ Hack in Rails Controllers \| by Eric Anderson \| Medium](https://medium.com/@eric.programmer/removing-the-hack-in-rails-controllers-52396463c40d)
- [Controller Best Practices: Don’t Hide Instance Variables – The Miners](https://blog.codeminer42.com/controller-best-practices-dont-hide-instance-variables-5e8bf067156/)
- [[Rails] Set instance variable using conditional assignment instead of before_action \| by Derek Fan \| Medium](https://medium.com/@derekfan/rails-set-instance-variable-using-conditional-assignment-instead-of-before-action-d7f226625d74)

**できることなら Rails の初学者が勘違いしないように before_action で `set_xxx` を呼ばないようにしたい。**

ラッキーなことに、今は Rails 7のリリース直前で scaffold にもかなり手が加えられています。
そうなんです。**今なら Rails 本体を修正できそうです。**

ということで、どのようなコントローラーを生成すれば良いのか考えてみました。

## 案1: 各アクションでインスタンス変数に代入する

`set_xxx` が良いパターンだと勘違いさせないようにbefore_actionをやめて、各アクションでインスタンス変数に代入すればいいのです。

```ruby
class MessagesController < ApplicationController
  # (省略)

  # GET /messages/1
  def show
    @message = find_message
  end

  # (省略)
  
  # PATCH/PUT /messages/1
  def update
    @message = find_message
    if @message.update("message_params")
      redirect_to @message, notice: "Message was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end
    
  # (省略)
  
  private
    def find_message
      Message.find(params[:id])
    end
    
    # (省略)
```

おぉ、いい感じ！
これなら初学者がアンチパターンにおちいってしまうことはないでしょう。

将来、 `find_message` がログインユーザーのメッセージを対象とすることに変わっても、

```ruby
def find_message
  current_user.messages.find(params[:id])
end
```

みたいな感じで `find_message` だけを変更すれば良いですしね。

でも...

これではダメなんです。

というのも、`set_xxx` のテンプレートには以下のコメントがあります。
[railties/lib/rails/generators/rails/scaffold_controller/templates/controller.rb.tt#L54](https://github.com/rails/rails/blob/6c51242ef215f87ad3ed05d9af05369dc5dda34f/railties/lib/rails/generators/rails/scaffold_controller/templates/controller.rb.tt#L54) より
```ruby
    # Use callbacks to share common setup or constraints between actions.
    def set_<%= singular_table_name %>
      @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    end
```

> Use callbacks to share common setup or constraints between actions.
> アクション間で共通の設定や制約を共有するには、コールバックを使用します。

そうなんです。
実は `set_xxx` はコントローラーにはコールバックの利用例でもあったのです。

だから、単純に削除するのはダメで、削除するなら別のコールバックの利用例を追加しないといけません。

## 案2: 検討中。次回に続く

1日考えてみましたが、良い例は思いつきませんでした。
あるモデル単体のコントローラーの初期に、コールバックの素敵な利用例って、難易度が高すぎます。

なにかいつになるかわかりませんが、思いついたときに続きを書きます。
