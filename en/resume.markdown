---
layout: default
lang: en
title: "Currículo"
---

{% assign lang = page.lang | default: site.language %}

<!-- SOBRE -->
{% assign about = site.data.about[lang] %}
{% if about %}
    ## Sobre
    {{ about.summary | markdownify }}
{% endif %}

---

<!-- EXPERIÊNCIA -->
{% assign experiences = site.data.experience[lang] %}
{% if experiences %}
    ## Experiência Profissional
    {% for experience in experiences.roles %}
        ### {{ experience.role }}
        **{{ experience.company }}**  
        🕓 {{ experience.time }} ({{ experience.period }})  
        {% if experience.details %}
            {{ experience.details | markdownify }}
        {% endif %}

        {% if experience.highlights %}
            {% for highlight in experience.highlights %}
                **Tecnologias**
            <ul>
            {% for item in highlight.items %}
                <li>{{ item.name }}</li>
            {% endfor %}
            </ul>
            {% endfor %}
        {% endif %}

    {% endfor %}
{% endif %}

---

<!-- HABILIDADES -->
{% assign skills = site.data.skills[lang] %}
{% if skills %}
    ## Habilidades
    {% for category in skills.categories %}
        ### {{ category.name }}
        <ul>
            {% for skill in category.toolset %}
            <li>{{ skill.name }}</li>
            {% endfor %}
        </ul>
    {% endfor %}
{% endif %}
