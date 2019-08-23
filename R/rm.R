#' Remove an extended attribute
#'
#' @md
#' @param path target path (file or dir); this is auto-expanded
#' @param name xattr name to retrieve
#' @param follow_symlinks if `FALSE` get xattr of the symlink vs the target it references
#' @export
#' @example inst/examples/ex1.R
rm_xattr <- function(path, name, follow_symlinks=TRUE) {

  path <- path.expand(path[1])
  if (!file.exists(path)) stop("File not found.", call.=FALSE)

  name <- handle_user_prefix_param(name)

  ret <- rcpp_rm_xattr(path, name, follow_symlinks)

  if (ret != 0L) warning(sprintf("Error %s while removing attribute.", ret), call. = FALSE, immediate. = TRUE)

  return(invisible(ret == 0L))

}

#' @rdname rm_xattr
#' @export
remove_xattr <- rm_xattr