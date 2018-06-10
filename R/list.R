#' List attributes
#'
#' @md
#' @param path target path (file or dir); this is auto-expanded
#' @param follow_symlinks if `FALSE` get xattr of the symlink vs the target it references
#' @export
#' @example inst/examples/ex1.R
list_xattrs <- function(path, follow_symlinks=TRUE) {

  path <- path.expand(path)
  if (!file.exists(path)) stop("File not found.", call.=FALSE)

  ret <- rcpp_list_xattrs(path, follow_symlinks)

  ret <- handle_user_prefix_return(ret)
  
  return(ret)

}
