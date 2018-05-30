# Less cool counterparts to purrr's side-effect capture-rs
#
# Most of the helper functions are 100% from output.R in purrr repo
#
# @param quiet Hide errors (`TRUE`, the default), or display them
#   as they occur?
# @param otherwise Default value to use when an error occurs.
#
# @return `safely`: wrapped function instead returns a list with
#   components `result` and `error`. One value is always `NULL`.
#
#   `quietly`: wrapped function instead returns a list with components
#   `result`, `output`, `messages` and `warnings`.
#
#   `possibly`: wrapped function uses a default value (`otherwise`)
#   whenever an error occurs.
safely <- function(.f, otherwise = NULL, quiet = TRUE) {
  function(...) capture_error(.f(...), otherwise, quiet)
}

capture_error <- function(code, otherwise = NULL, quiet = TRUE) {
  tryCatch(
    list(result = code, error = NULL),
    error = function(e) {
      if (!quiet)
        message("Error: ", e$message)

      list(result = otherwise, error = e)
    },
    interrupt = function(e) {
      stop("Terminated by user", call. = FALSE)
    }
  )
}

s_read_xml <- safely(xml2::read_xml)
