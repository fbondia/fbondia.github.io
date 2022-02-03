---
layout: default
---

{% include about.html %}

{% include skills.html %}

{% include experiences.html %}

{% unless site.data.sidebar.education %}
  {% include education.html %}
{% endunless %}

{% include projects.html %}
