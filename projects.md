---
layout: page
title: Projects
permalink: /projects/
---
<ul>
{% for p in site.data.projects %}
  <li><a href="{{ p.url }}">{{ p.title }}</a></li>
{% endfor %}
</ul>
