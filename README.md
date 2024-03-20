## The Risky Pipeline

> This project is a fork and has been modified from [Agus Makmum's Modified Simple Grey Theme for Jekyll](https://github.com/agusmakmun/agusmakmun.github.io)
> and the search posts using [Super Search](https://github.com/chinchang/super-search)

Use [GitHub Pages](https://pages.github.com/) with [GitHub Actions](https://docs.github.com/en/actions/learn-github-actions) to manage and update a Jekyll-based website using a custom Jekyll theme, based on a modified version of the `Simple Grey Theme`.

### Demo
* [https://adamlechnos.com](https://adamlechnos.com)


#### Features

* Sitemap and XML Feed
* Pagination on the homepage
* Posts under category
* Post categories on the homepage under posts
* Code fencing and GitHub Gist syntax highlighting
* Buy Me a Coffee Integration
* Automated generation of GitHub topics list, parsed from Code & Artifacts page
* Realtime Search Posts _(title & description)_ by query.
* Related Posts
* Highlight pre
* Next & Previous Post
* Disqus comment
* Projects page & Detail Project page
* Share on social media
* Google analytics
* HTML Minify _(Compress HTML)_ using [Jekyll Compress HTML](https://github.com/penibelst/jekyll-compress-html)

#### Screenshot

![Screenshot Post Page](https://raw.githubusercontent.com/Adam-Lechnos/screenshots/main/web-app-dev/screenshot-adamlechnos-post-example.png  "Screenshot Post Page")

### Install & Configuration

1. Learn more about [GitHub Pages with Jekyll](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll)
2. Fork this repository
3. Edit site settings inside the file of `_config.yml`
4. Edit your projects at the file of `projects.md`, `_data/projects.json`, and inside path of `_project/` _(for detail project)_.
5. Edit about yourself inside the file of `about.md`

### How to Use?

**a. Add new Category**

All categories are saved inside the path of `category/`, you can see the existing categories.

**b. Add new Posts**

* All posts bassed on markdown syntax _(please googling)_. allowed extensions is `*.markdown` or `*.md`.
* This file can found at the path of `_posts/`.
* and the name of files are following `<date:%Y-%m-%d>-<slug>.<extension>`, for example:

```
2013-09-23-welcome-to-jekyll.md

# or

2013-09-23-welcome-to-jekyll.markdown
```

Inside the file of it,

```
---
layout: post                          # (require) default post layout
title: "Your Title"                   # (require) a string title
date: 2016-04-20 19:51:02 +0700       # (require) a post date
categories: [python, django]          # (custom) some categories, but make sure these categories already exist inside the path of `category/`
tags: [foo, bar]                      # (custom) tags only for meta `property="article:tag"`
image: Broadcast_Mail.png             # (custom) image only for meta `property="og:image"`, save your image inside the path of `static/img/_posts`
---

# Your content post with markdown syntax goes here...
```


#### Installing in your local

```
bundle install
jekyll serve
```

**Updating the `Gemfile.lock`**

```
bundle update
```

### Contributing

Feel free to [open a bug](https://github.com/adam-lechnos/adam-lechnos.github.io/issues) or [contribute to code](https://github.com/adam-lechnos/adam-lechnos.github.io/pulls)!
