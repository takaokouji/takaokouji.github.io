---
layout: archive
title: "サイトマップ"
permalink: /sitemap/
author_profile: false
sitemap: false
---

全記事とページの一覧です。
For you robots out there is an [XML version]({{ "sitemap.xml" | relative_url }}) available for digesting as well.

<h2>ページ</h2>
{% for post in site.pages %}
  {% if post.sitemap %}
  {% include archive-single.html %}
  {% endif %}
{% endfor %}

<h2>記事</h2>
{% for post in site.posts %}
  {% include archive-single.html %}
{% endfor %}

{% capture written_label %}'None'{% endcapture %}

{% for collection in site.collections %}
{% unless collection.output == false or collection.label == "posts" %}
  {% capture label %}{{ collection.label }}{% endcapture %}
  {% if label != written_label %}
  <h2>{{ label }}</h2>
  {% capture written_label %}{{ label }}{% endcapture %}
  {% endif %}
{% endunless %}
{% for post in collection.docs %}
  {% unless collection.output == false or collection.label == "posts" %}
  {% include archive-single.html %}
  {% endunless %}
{% endfor %}
{% endfor %}
