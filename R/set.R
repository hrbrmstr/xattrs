#' Set or modify an extended attribute
#'
#' @md
#' @param path target path (file or dir); this is auto-expanded
#' @param name xattr name to retrieve
#' @param value raw vector of value to set
#' @param follow_symlinks if `FALSE` get xattr of the symlink vs the target it references
#' @export
#' @example inst/examples/ex1.R
set_xattr <- function(path, name, value, follow_symlinks=TRUE) {

  path <- path.expand(path[1])
  if (!file.exists(path)) stop("File not found.", call.=FALSE)

  name <- handle_user_prefix_param(name[1])

  value <- value[1]
  if (is.character(value)) value <- charToRaw(value)

  ret <- rcpp_set_xattr(path, name, value, follow_symlinks)

  if (ret != 0L) warning(sprintf("Error %s while setting attribute.", ret))

  return(invisible(ret == 0L))

}