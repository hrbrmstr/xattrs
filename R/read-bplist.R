#' Tests whether a raw vector is really a binary plist
#'
#' @md
#' @param rawv raw vector to test
#' @export
is_bplist <- function(rawv) {
  all(c(0x62, 0x70, 0x6c, 0x69, 0x73, 0x74, 0x30, 0x30) == rawv[1:8])
}

#' Convert binary plist to something usable in R
#'
#' @md
#' @param raw_bplist raw vector containing the contents of a binary plist
#' @return `list`
#' @export
read_bplist <- function(raw_bplist) {
  tf <- tempfile(fileext=".plist")
  on.exit(unlink(tf), add=TRUE)
  writeBin(raw_bplist, tf, useBytes = TRUE)
  convert_plist(tf)
}

