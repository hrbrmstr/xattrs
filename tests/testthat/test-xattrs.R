context("Get / set / check / read / list / size xattrs ops work")
test_that("we can do something", {

  tf <- tempfile(fileext = ".csv")
  write.csv(mtcars, tf)

  expect_false(has_xattrs(tf))
  expect_identical(get_xattr(tf, "is.rud.setting"), character(0))

  # temporarily set attribute using OS tool
  system(paste0(ifelse(grepl("darwin", sessionInfo()$platform),
                       "xattr -s a.test    Avalue ",
                       "attr  -s a.test -V Avalue "), tf),
         ignore.stdout = TRUE)

  expect_true(has_xattrs(tf))
  expect_identical(list_xattrs(tf), "user.a.test")
  expect_identical(get_xattr(tf, "user.a.test"), "Avalue")
  expect_equal(get_xattr_size(tf, "user.a.test"), 6L)
  expect_identical(class(get_xattr_df(tf)), c("tbl_df", "tbl", "data.frame"))

  # set_xattr(tf, "is.rud.setting.a", "first attribut")
  #
  # expect_equal(get_xattr(tf, "is.rud.setting.a"), "first attribut")
  # expect_equal(get_xattr_size(tf, "is.rud.setting.a"), 14)
  #
  # expect_true(has_xattrs(tf))
  #
  # set_xattr(tf, "is.rud.setting.b", "second attribute")
  # expect_equal(get_xattr(tf, "is.rud.setting.b"), "second attribute")
  # expect_equal(get_xattr_size(tf, "is.rud.setting.b"), 16)
  #
  # set_xattr(tf, "is.rud.setting.a", "first attribute")
  # expect_equal(get_xattr(tf, "is.rud.setting.a"), "first attribute")
  # expect_equal(get_xattr_size(tf, "is.rud.setting.a"), 15)
  #
  # expect_equal(length(list_xattrs(tf)), 2)
  #
  # expect_equal(nrow(get_xattr_df(tf)), 2)
  #
  # rm_xattr(tf, "is.rud.setting")
  # expect_equal(get_xattr(tf, "is.rud.setting"), character(0))

  unlink(tf)

})
