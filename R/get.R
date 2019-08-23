#' Get an extended attribute
#'
#' @md
#' @param path target path (file or dir); this is auto-expanded
#' @param name xattr name to retrieve
#' @param follow_symlinks if `FALSE` get xattr of the symlink vs the target it references
#' @export
#' @example inst/examples/ex1.R
get_xattr <- function(path, name, follow_symlinks=TRUE) {

  path <- path.expand(path[1])
  if (!file.exists(path)) stop("File not found.", call.=FALSE)

  name <- handle_user_prefix_param(name)

  ret <- rcpp_get_xattr(path, name, follow_symlinks)

  ret

}

#' Get raw contents of an extended attribute
#'
#' @md
#' @inheritParams get_xattr
#' @export
#' @example inst/examples/ex1.R
get_xattr_raw <- function(path, name, follow_symlinks=TRUE) {

  path <- path.expand(path[1])
  if (!file.exists(path)) stop("File not found.", call.=FALSE)

  name <- handle_user_prefix_param(name[1])

  ret <- rcpp_get_xattr_raw(path, name, follow_symlinks)

  ret

}

#' Get size of an extended attribute
#'
#' @md
#' @inheritParams get_xattr
#' @export
#' @example inst/examples/ex1.R
get_xattr_size <- function(path, name, follow_symlinks=TRUE) {

  path <- path.expand(path[1])
  if (!file.exists(path)) stop("File not found.", call.=FALSE)

  name <- handle_user_prefix_param(name[1])

  ret <- rcpp_get_xattr_size(path, name, follow_symlinks)

  ret

}

