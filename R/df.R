#' Retrieve a data frame of xattr names, sizes and (raw) contents for a target path
#'
#' @md
#' @param path path target path (file or dir); this is auto-expanded
#' @param follow_symlinks if `FALSE` get xattr of the symlink vs the target it references
#' @export
#' @example inst/examples/ex1.R
get_xattr_df <- function(path, follow_symlinks = TRUE) {

  path <- path.expand(path[1])
  xattr_list <- rcpp_get_xattr_df(path, follow_symlinks)
  class(xattr_list$contents) <- c("AsIs", "list")
  xdf <- as.data.frame(xattr_list, stringsAsFactors=FALSE)
  attributes(xdf$contents) <- NULL
  xdf$name <- handle_user_prefix_return(xdf$name)
  class(xdf) <- c("tbl_df", "tbl", "data.frame")
  xdf

}

#' @rdname get_xattr_df
#' @export
read_xattrs <- get_xattr_df