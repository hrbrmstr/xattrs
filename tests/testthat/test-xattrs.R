context("Get / set / check / read / list / size xattrs ops work")
test_that("we can do something", {

  tf <- tempfile(fileext = ".csv")
  write.csv(mtcars, tf)

  expect_false(has_xattrs(tf))
  expect_identical(get_xattr(tf, "is.rud.setting"), character(0))

  set_xattr(tf, "is.rud.setting.a", "first attribut")

  expect_equal(get_xattr(tf, "is.rud.setting.a"), "first attribut")
  expect_equal(get_xattr_size(tf, "is.rud.setting.a"), 14)

  expect_true(has_xattrs(tf))

  set_xattr(tf, "is.rud.setting.b", "second attribute")
  expect_equal(get_xattr(tf, "is.rud.setting.b"), "second attribute")
  expect_equal(get_xattr_size(tf, "is.rud.setting.b"), 16)

  set_xattr(tf, "is.rud.setting.a", "first attribute")
  expect_equal(get_xattr(tf, "is.rud.setting.a"), "first attribute")
  expect_equal(get_xattr_size(tf, "is.rud.setting.a"), 15)

  expect_equal(length(list_xattrs(tf)), 2)

  expect_equal(nrow(get_xattr_df(tf)), 2)

  rm_xattr(tf, "is.rud.setting")
  expect_equal(get_xattr(tf, "is.rud.setting"), character(0))

  unlink(tf)

})
