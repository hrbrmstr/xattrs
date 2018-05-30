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

  plutil <- find_plutil()

  if (plutil == "plistutil") {
    sys::exec_internal(
      plutil, arg=c("-i", path)
    ) -> res
  } else {
    sys::exec_internal(
      plutil,
      args = c("-convert", "xml1", path, "-o", "-")
    ) -> res
  }

  out <- xml2::read_xml(res$stdout)

  xml2::as_list(out)

}
