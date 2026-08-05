---
layout: default
lang: pt
---

<nav class="tab-navigation" role="tablist" aria-label="Seções do currículo">
  <button class="tab-button is-active" id="tab-button-about" type="button" role="tab" aria-selected="true" aria-controls="tab-about" data-tab-target="tab-about">Sobre</button>
  <button class="tab-button" id="tab-button-projects" type="button" role="tab" aria-selected="false" aria-controls="tab-projects" data-tab-target="tab-projects" tabindex="-1">Projetos</button>
  <button class="tab-button" id="tab-button-experience" type="button" role="tab" aria-selected="false" aria-controls="tab-experience" data-tab-target="tab-experience" tabindex="-1">Experiência</button>
</nav>

<div class="tab-panel is-active" id="tab-about" role="tabpanel" aria-labelledby="tab-button-about">
  {% include about.html %}
</div>

<div class="tab-panel" id="tab-projects" role="tabpanel" aria-labelledby="tab-button-projects" hidden>
  {% include projects.html %}
</div>

<div class="tab-panel" id="tab-experience" role="tabpanel" aria-labelledby="tab-button-experience" hidden>
  {% include experiences.html %}
</div>
