#!/usr/bin/env Rscript

# An R script to build the markdown files for my notes on the "Statistical
# Rethinking" textbook. Each notes file is a R Markdown file and will be
# presented on the website as a "post".

library(glue)
library(rmarkdown)
library(tidyverse)
library(conflicted)

conflict_prefer("filter", "dplyr")

rethinking_dir <- file.path("..", "..", "R", "statistical-rethinking")
rethinking_rmds <- tibble(
  rmd_path = list.files(rethinking_dir,
                        full.names = TRUE,
                        pattern = "^ch.+Rmd$")
) %>%
    mutate(chapter = str_extract(basename(rmd_path),
                                 "(?<=ch)[:digit:]+(?=_)"),
           chapter = as.numeric(chapter)) %>%
    arrange(chapter)

# Check to make sure all files were found.
stopifnot(nrow(rethinking_rmds) == 14)
stopifnot(all(1:14 %in% rethinking_rmds$chapter))


strip_file_name <- function(x) tools::file_path_sans_ext(basename(x))


POSTS_DIR <- file.path("content", "post")

get_post_directory <- function(rmd_path) {
    post_dir <- strip_file_name(rmd_path)
    post_dir <- file.path(POSTS_DIR, post_dir)
    return(post_dir)
}

reset_post_directory <- function(rmd_path) {
    post_dir <- get_post_directory(rmd_path)
    if (dir.exists(post_dir)) {
        message("Reseting post directory.")
        unlink(post_dir, recursive = TRUE)
    }
    dir.create(post_dir, recursive = TRUE)

}

# Clear the cache of a R Markdown file. (not used)
clear_rmarkdown_cache <- function(rmd_path) {
    cache_path <- paste0(tools::file_path_sans_ext(rmd_path), "_cache")
    if (dir.exists(cache_path)) {
        message("Clearing R Markdown cache.")
        unlink(cache_path, recursive = TRUE)
    }
}


# If the chapter has a directory in the assets directory of
# "statistical-rethinking", it is copied to the post directory.
copy_assets_if_needed <- function(rmd_path, chapter) {
    old_assets_dir <- file.path(rethinking_dir,
                                "assets",
                                glue("ch{chapter}"))

    new_assets_dir <- file.path(get_post_directory(rmd_path),
                                "assets",
                                basename(old_assets_dir))

    if (dir.exists(old_assets_dir)) {
        message(glue("Copying assets for chapter {chapter}"))
        if (!dir.exists(new_assets_dir)) {
            dir.create(new_assets_dir, recursive = TRUE)
        }
        all_asset_files <- list.files(old_assets_dir, full.names = TRUE)
        walk(all_asset_files, function(a) {
            file.copy(from = a, to = file.path(new_assets_dir, basename(a)))
        })
    }

    invisible(NULL)
}


get_index_path <- function(rmd_path) {
    file.path(get_post_directory(rmd_path), "index.md")
}


get_markdown_path <- function(rmd_path) {
    md_file <- paste0(strip_file_name(rmd_path), ".md")
    file.path(get_post_directory(rmd_path), md_file)
}


copy_index_template <- function(rmd_path) {
    template_path <- file.path("content", "post", "index_template.txt")
    index_path <- get_index_path(rmd_path)
    file.copy(template_path, index_path)
    invisible(NULL)
}


customize_index_md <- function(index_md_path, chapter, title, rmd_file) {
    rmd_file <- basename(rmd_file)
    template <- readLines(index_md_path)
    template <- map_chr(template, function(l) {
            cond1 <- str_length(l) == 0
            cond2 <- str_detect(l, "\\{")
            if (!cond1 & cond2) {
                return(glue(l))
            } else {
                return(l)
            }
        }
    )

    writeLines(template, index_md_path)
    invisible(NULL)
}


fix_asset_paths <- function(index_file, rmd_path) {
    img_dir_name <- paste0(strip_file_name(rmd_path), "_files")

    readLines(index_file) %>%
        unlist() %>%
        str_replace_all(img_dir_name, glue("assets/{img_dir_name}")) %>%
        writeLines(index_file)
}


fix_github_math_format <- function(index_file) {
    readLines(index_file) %>%
        map_chr(function(l) {
            l %>%
                str_replace_all("\\\\\\(", "$") %>%
                str_replace_all("\\\\\\)", "$") %>%
                str_replace_all("\\\\\\[", "$$") %>%
                str_replace_all("\\\\\\]", "$$") %>%
                str_replace("\\\\\\\\", "$$\n$$")
        }) %>%
        writeLines(index_file)
}


extract_title <- function(rmd_path) {
    title <- rmd_path %>%
        strip_file_name() %>%
        str_remove("^ch[:digit:]+_") %>%
        str_replace_all("-", " ") %>%
        str_to_title()
    return(title)
}


merge_index_and_md <- function(rmd_path) {
    index_path <- get_index_path(rmd_path)
    index_lines <- readLines(index_path)
    md_lines <- readLines(get_markdown_path(rmd_path))
    writeLines(
        c(unlist(index_lines),
          unlist(md_lines)[c(-1, -2)]),
        index_path
    )
    invisible(NULL)
}


source_scripts <- function() {
    fs <- list.files(file.path(rethinking_dir, "scripts"),
                     full.names = TRUE,
                     pattern = "R$")
    walk(fs, source)
    invisible(NULL)
}


copy_rmarkdown_output <- function(rmd_path) {
    post_dir <- get_post_directory(rmd_path)

    # Copy the markdown file.
    file.copy(
        paste0(tools::file_path_sans_ext(rmd_path), ".md"),
        post_dir
    )

    # Copy the accompanying files to "assets/".
    assets_dir <- file.path(post_dir, "assets")
    if (!dir.exists(assets_dir)) { dir.create(assets_dir) }
    file.copy(
        from = file.path(rethinking_dir,
                         paste0(strip_file_name(rmd_path), "_files")),
        to = assets_dir,
        recursive = TRUE
    )
}


compile_rmd_notes <- function(rmd_path, chapter) {
    message(paste0("Working on chapter ", chapter, "."))

    reset_post_directory(rmd_path)

    copy_assets_if_needed(rmd_path, chapter)

    # render(input = rmd_path,
    #        output_format = github_document(html_preview = FALSE,
    #                                        keep_html = FALSE))

    message("Copying R Markdown results to 'post/'")
    copy_rmarkdown_output(rmd_path)

    message("Creating and merging with 'index.md'.")
    copy_index_template(rmd_path)
    customize_index_md(get_index_path(rmd_path),
                       chapter = str_pad(chapter, width = 2,
                                         side = "left", pad = "0"),
                       title = extract_title(rmd_path),
                       rmd_file = basename(rmd_path))

    merge_index_and_md(rmd_path)
    fix_github_math_format(get_index_path(rmd_path))
    fix_asset_paths(get_index_path(rmd_path), rmd_path)
    message(glue("Finished chapter {chapter}\n\n"))
    invisible(NULL)
}


rethinking_rmds %>%
    purrr::pwalk(compile_rmd_notes)

