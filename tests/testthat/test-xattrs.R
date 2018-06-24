context("Get / set / check / read / list / size xattrs ops work")
test_that("we can do something", {

  # a target for a temporary file for testing
  tf <- tempfile(fileext = ".csv")
  write.csv(mtcars, tf)

  # a target for a link to the temporary file
  tl <- tempfile()

  # no attribute set so far
  expect_false(has_xattrs(tf))
  expect_identical(get_xattr(tf, "is.rud.setting"), character(0))

  # setting attribute using respective OS tool
  if(grepl("darwin", utils::sessionInfo()$platform)) {
    sys::exec_internal("xattr", arg = c("-w", "is.rud.setting", "another attribute", tf), error = FALSE)
  }
  if(grepl("linux", utils::sessionInfo()$platform)) {
    sys::exec_internal("attr", arg = c("-s", "is.rud.setting", "-V", "another attribute", tf), error = FALSE)
  }

  # reading and deleting with internal functions
  if(grepl("darwin|linux", utils::sessionInfo()$platform)) {

    # check attributes set with OS tool
    expect_true(has_xattrs(tf))
    expect_identical(list_xattrs(tf), "is.rud.setting")
    expect_identical(get_xattr(tf, "is.rud.setting"), "another attribute")
    expect_equal(get_xattr_size(tf, "is.rud.setting"), 17L)
    expect_identical(class(get_xattr_df(tf)), c("tbl_df", "tbl", "data.frame"))
    expect_true(rm_xattr(tf, "is.rud.setting"))

    # set and check attribute on tf
    expect_true(set_xattr(tf, "is.rud.setting", "attribute value"))
    expect_true(has_xattrs(tf))
    # remove
    expect_true(rm_xattr(tf, "is.rud.setting"))

  }

  # setting attribute using respective OS tool on symbolic link
  # record in lnok if successful to inform further testing below
  if(grepl("darwin", utils::sessionInfo()$platform)) {
    sys::exec_internal("ln", arg = c("-s", tf, tl))
    lnok <- sys::exec_internal("xattr", arg = c("-s", "-w", "is.rud.setting.ln", "another attribute", tl), error = FALSE)
  }
  if(grepl("linux", utils::sessionInfo()$platform)) {
    sys::exec_internal("ln", arg = c("-s", tf, tl))
    lnok <- sys::exec_internal("attr", arg = c("-s", "is.rud.setting.ln", "-V", "another attribute", tl), error = FALSE)
  }

  # check attribute on symbolic link only
  if(exists("lnok") && !length(lnok$stderr)){

    # check attributes set with OS tool
    expect_false(has_xattrs(tf))
    expect_true(has_xattrs(tl, follow_symlinks = FALSE))
    expect_false(has_xattrs(tl, follow_symlinks = TRUE))
    expect_identical(list_xattrs(tl, follow_symlinks = FALSE), "is.rud.setting.ln")
    expect_identical(get_xattr(tl, "is.rud.setting.ln", follow_symlinks = FALSE), "another attribute")
    expect_equal(get_xattr_size(tl, "is.rud.setting.ln", follow_symlinks = FALSE), 17L)
    expect_identical(class(get_xattr_df(tl, follow_symlinks = FALSE)), c("tbl_df", "tbl", "data.frame"))
    expect_true(rm_xattr(tl, "is.rud.setting.ln", follow_symlinks = FALSE))

    # set and check attribute on tl
    expect_true(set_xattr(tl, "is.rud.setting.ln", "attribute value", follow_symlinks = FALSE))
    expect_false(has_xattrs(tf))
    expect_true(set_xattr(tl, "is.rud.setting.f", "attribute data", follow_symlinks = TRUE))
    expect_true(has_xattrs(tl, follow_symlinks = FALSE))
    expect_true(has_xattrs(tl, follow_symlinks = TRUE))
    expect_identical(list_xattrs(tl, follow_symlinks = FALSE), "is.rud.setting.ln")
    expect_identical(list_xattrs(tl, follow_symlinks = TRUE), "is.rud.setting.f")
    expect_identical(get_xattr(tl, "is.rud.setting.ln", follow_symlinks = FALSE), "attribute value")
    expect_equal(get_xattr_size(tl, "is.rud.setting.ln", follow_symlinks = FALSE), 15L)
    expect_identical(class(get_xattr_df(tl, follow_symlinks = FALSE)), c("tbl_df", "tbl", "data.frame"))
    #
    expect_true(rm_xattr(tl, "is.rud.setting.ln", follow_symlinks = FALSE))
    expect_true(rm_xattr(tl, "is.rud.setting.f", follow_symlinks = TRUE))
    expect_false(has_xattrs(tf))
    expect_false(has_xattrs(tl, follow_symlinks = FALSE))

   }

  # setting, reading, deleting attributes with internal functions
  expect_true(set_xattr(tf, "is.rud.setting.a", "first attribut"))
  expect_equal(get_xattr_size(tf, "is.rud.setting.a"), 14L)
  expect_true(has_xattrs(tf))
  #
  expect_true(set_xattr(tf, "is.rud.setting.b", "second attribute"))
  expect_equal(get_xattr(tf, "is.rud.setting.b"), "second attribute")
  expect_equal(get_xattr_size(tf, "is.rud.setting.b"), 16L)
  #
  expect_true(set_xattr(tf, "is.rud.setting.a", "first attribute"))
  expect_equal(get_xattr(tf, "is.rud.setting.a"), "first attribute")
  expect_equal(get_xattr_size(tf, "is.rud.setting.a"), 15L)
  #
  expect_equal(length(list_xattrs(tf)), 2)
  expect_equal(nrow(get_xattr_df(tf)), 2)
  expect_true(rm_xattr(tf, "is.rud.setting.a"))
  expect_false(suppressWarnings(rm_xattr(tf, "is.rud.setting.a")))
  expect_equal(get_xattr(tf, "is.rud.setting.a"), character(0))

  unlink(tf)
  unlink(tl)

})
