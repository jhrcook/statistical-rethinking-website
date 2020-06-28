---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Chapter 01. The Golem Of Prague"
subtitle: ""
summary: ""
authors: []
tags: [chapter_01]
categories: []
date: 2020-06-27T13:48:22-04:00
lastmod: 2020-06-27T13:48:22-04:00
featured: false
draft: false

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder.
# Focal points: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight.
image:
  caption: ""
  focal_point: ""
  preview_only: true

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects: []

links:
 - name: Repository
   url: https://github.com/jhrcook/statistical-rethinking
   icon_pack: fab
   icon: github
 - name: R Markdown Notebook
   url: https://github.com/jhrcook/statistical-rethinking/ch1_the-golem-of-prague.Rmd
   icon_pack: fab
   icon: r-project

---

The first two sections are spent describing some of the general probmes
that statisticians and researchers face is designing statistical tests
and models.

## 1.3 Tools for golem engineering

  - use models for several distinct purpose:
      - designing inquiry
      - extracting information from data
      - making predictions
  - this book focuses on the following tools towards these purposes:
      - Bayesian data analysis
      - model comparison
      - multilevel models
      - graphical causal models
  - this book focuses mostly on code - how to do things (“golem
    engineering”)

### 1.3.1 Bayesian data analysis

  - Bayesian data analysis takes a question in the form of a model and
    uses logic to produce an answer int he form of probability
    distributions.
  - it is like counting the number of ways the data could happen
    according to some assumptions
      - things that can happen more ways are more plausible

### 1.3.2 Model comparison and prediction

  - there are many ways to compare models
  - we will learn about “cross-validation” and “information criteria” as
    metrics of predictive power of a model
  - this will introduce the phenomenon of more complex models making
    worse predictions: “over-fitting”

### 1.3.3. Multilevel models

  - models contain parameters which can sometimes stand-in for other
    missing models
      - given smoe model of how the parameter gets its value, the new
        model can be inserted in place of the parameter
      - this cretes a final model with multiple levels of uncertainty
  - these models are also called “hierarchical,” “random effects,”
    “varying effects,” or “mixed effects” models
  - multilevel models can help fight overfitting using “partial pooling”
    (covered in Chapter 13)
  - they generally apply when there are clusters or groups of
    measureents that may differ from one another

### Graphical causal models

  - one form of prediction, mentioned above, is what will the outcome be
    in the future
  - another type is causal prediction: what process causes the other
      - this is essential knowledge for using a model to intervene in
        the world
