#' Work With Filesystem Object Extended Attributes
#'
#' Filesystem path target extended attributes store extra, customizable, small bits of
#' info. For example, author name, file character encoding, short comments, security
#' status, etc. Methods are provided to list, extract and work with these attributes.
#'
#' @md
#' @name xattrs
#' @docType package
#' @author Bob Rudis (bob@@rud.is)
#' @useDynLib xattrs
#' @importFrom xml2 read_xml as_list
#' @importFrom sys exec_internal
#' @importFrom Rcpp sourceCpp
#' @example inst/examples/ex1.R
"_PACKAGE"
