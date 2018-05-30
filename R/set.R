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

  value <- value[1]

  path <- path.expand(path)
  if (!file.exists(path)) stop("File not found.", call.=FALSE)

  if (is.character(value)) value <- charToRaw(value)

  ret <- rcpp_set_xattr(path, name, value, follow_symlinks)

  if (ret > 0) warning(sprintf("Error %s while setting attribute.", ret))

}