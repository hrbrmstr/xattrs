find_plutil <- function() {
  x <- Sys.which("plutil")
  if (x == "") x <- Sys.which("plistutil")
  if (x == "") {
    message(
      "One of 'plutil' or 'plistutil' not found and is requried.\n",
      "On macOS, 'plutil' should come with the OS.\n",
      "Linux folks can do the equivalent of:\n",
      "   sudo apt-get install libplist-utils\n",
      "to install 'plistutil' (a compatible alternative to 'plutil')."
    )
    stop(call.=FALSE)
  }
  return(unname(x))
}

convert_plist <- function(path) {

  path <- path[1]

  plutil <- find_plutil()

  if (plutil == "plistutil") {
    sys::exec_internal(
      plutil,
      arg=c("-i", path),
      error = FALSE
    ) -> res
  } else {
    sys::exec_internal(
      plutil,
      args = c("-convert", "xml1", path, "-o", "-"),
      error = FALSE
    ) -> res
  }

  if (!is.null(res$stdout)) {
    out <- s_read_xml(res$stdout)
    if (is.null(out$result)) return(list(NA))
    xml2::as_list(out$result)
  } else {
    return(list(NA))
  }

}

# Linux: attributes are prefixed with a namespace, that is,
# an attribute has the form: namespace.attribute
# Examples: user.mime_type, trusted.md5sum, system.posix_acl_access
# for xattrs, the interest is primarily to access the user
# namespace. When a namespace is missing, "user" is used as namespace.
# https://linux.die.net/man/5/attr
#
# Removing the namespace "user" from attribute names used in
# parameters or when listing attributes enables to use the same
# R code across platforms

linux_namespaces <- c("user", "security", "system", "trusted")

#' handle_user_prefix_param
#' @param stringvector vector of strings with attribute names
#' @return stringvector adjusted with required namespace (Linux)
#' @keywords internal
#' @importFrom utils sessionInfo
handle_user_prefix_param <- function(stringvector){

  # vectorised function to work on linux where attribute
  # name are to be prefixed with "user." for parameters

  if(grepl("linux", sessionInfo()$platform)) {
    unname(sapply(stringvector, function(x)
      ifelse(grepl(paste0("^(", paste0(linux_namespaces, collapse = "|"), ")[.]"), x), x, paste0("user.", x))))
  } else {
    stringvector
  }
}

#' handle_user_prefix_return
#' @param stringvector vector of strings with attribute names
#' @return stringvector adjusted without namespace (Linux)
#' @keywords internal
#' @importFrom utils sessionInfo
handle_user_prefix_return <- function(stringvector){

  # vectorised function to work on linux where from
  # attribute names the prefix "user." should be removed

  if(grepl("linux", sessionInfo()$platform)) {
    unname(sapply(stringvector, function(x) ifelse(grepl("^user.", x), sub("^user.(.*)$", "\\1", x))))
  } else {
    stringvector
  }
}

