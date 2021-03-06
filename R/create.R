#' Create files, directories, or links
#'
#' These functions ensure that `path` exists; if it already exists it will
#' be left unchanged. That means that compared to [file.create()],
#' `file_create()` will not truncate an existing file, and compared to
#' [dir.create()], `dir_create()` will silently ignore
#' existing directories.
#'
#' @template fs
#' @param mode If file/directory is created, what mode should it have?
#'
#'   Links do not have mode; they inherit the mode of the file they link to.
#' @param recursive should intermediate directories be created if they do not
#'   exist?
#' @return The path to the created object (invisibly).
#' @name create
#' @examples
#' \dontshow{fs:::pkgdown_tmp(c("/tmp/filedd461e481b37", "/tmp/filedd46ff2c769"))}
#' x <- file_create(file_temp())
#' is_file(x)
#' # dir_create applied to the same path will fail
#' try(dir_create(x))
#'
#' x <- dir_create(file_temp())
#' is_dir(x)
#' # file_create applied to the same path will fail
#' try(file_create(x))
#' @export
file_create <- function(path, mode = "u=rw,go=r") {
  assert_no_missing(path)
  stopifnot(length(mode) == 1)

  mode <- as_fs_perms(mode)
  new <- path_expand(path)

  create_(new, mode)
  invisible(path_tidy(path))
}

#' @export
#' @rdname create
dir_create <- function(path, mode = "u=rwx,go=rx", recursive = TRUE) {
  assert_no_missing(path)
  stopifnot(length(mode) == 1)

  mode <- as_fs_perms(mode)
  new <- path_expand(path)

  paths <- path_split(new)
  for (p in paths) {
    if (length(p) == 1 || !isTRUE(recursive)) {
      mkdir_(p, mode)
    } else {
      p_paths <- Reduce(get("path", mode = "function"), p, accumulate = TRUE)
      if (is_absolute_path(p[[1]])) {
        p_paths <- p_paths[-1]
      }
      mkdir_(p_paths, mode)
    }
  }

  invisible(path_tidy(path))
}

#' @export
#' @rdname create
#' @param new_path The path where the link should be created.
#' @param symbolic Boolean value determining if the link should be a symbolic
#'   (the default) or hard link.
link_create <- function(path, new_path, symbolic = TRUE) {
  assert_no_missing(path)
  assert_no_missing(new_path)
  stopifnot(length(path) == length(new_path))

  old <- path_expand(path)
  new <- path_expand(new_path)

  if (isTRUE(symbolic)) {
    link_create_symbolic_(old, new)
  } else {
    link_create_hard_(old, new)
  }

  invisible(path_tidy(new_path))
}
