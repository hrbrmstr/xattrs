context("Get / set / check / read / list / size xattrs ops work")
test_that("we can do something", {

  tf <- tempfile(fileext = ".csv")
  write.csv(mtcars, tf)

  # no attribute set so far
  expect_false(has_xattrs(tf))
  expect_identical(get_xattr(tf, "is.rud.setting"), character(0))

  # setting attribute using respective OS tool and reading
  #
  if(grepl("darwin", utils::sessionInfo()$platform)) {
    
    system(paste0("xattr -s is.rud.setting 'another attribute' ", tf), ignore.stdout = TRUE)
    expect_true(has_xattrs(tf))
    expect_identical(list_xattrs(tf), "is.rud.setting")
    expect_identical(get_xattr(tf, "is.rud.setting"), "another attribute")
    
    # TO BE implemented with handle_user_prefix_{param,return}
    expect_equal(get_xattr_size(tf, "user.is.rud.setting"), 17L)
    expect_identical(class(get_xattr_df(tf)), c("tbl_df", "tbl", "data.frame"))

    # continue testing    
    expect_true(rm_xattr(tf, "is.rud.setting"))
  }
  #
  if(grepl("linux", utils::sessionInfo()$platform)) {
    
    system(paste0("attr -s is.rud.setting -V 'another attribute' ", tf), ignore.stdout = TRUE)
    expect_true(has_xattrs(tf))
    expect_identical(list_xattrs(tf), "is.rud.setting")
    expect_identical(get_xattr(tf, "is.rud.setting"), "another attribute")

    # TO BE implemented with handle_user_prefix_{param,return}
    expect_equal(get_xattr_size(tf, "user.is.rud.setting"), 17L)
    expect_identical(class(get_xattr_df(tf)), c("tbl_df", "tbl", "data.frame"))
    
    # continue testing    
    expect_true(rm_xattr(tf, "is.rud.setting"))
  }
  
  # setting and reading attribute with internal functions
  expect_true(set_xattr(tf, "is.rud.setting.a", "first attribut"))
  
  # TO BE implemented with handle_user_prefix_{param,return}
  expect_equal(get_xattr_size(tf, "user.is.rud.setting.a"), 14L)

  # continue testing
  expect_true(has_xattrs(tf))
  expect_true(set_xattr(tf, "is.rud.setting.b", "second attribute"))
  expect_equal(get_xattr(tf, "is.rud.setting.b"), "second attribute")
  
  # TO BE implemented with handle_user_prefix_{param,return}
  expect_equal(get_xattr_size(tf, "user.is.rud.setting.b"), 16L)

  # continue testing
  expect_true(set_xattr(tf, "is.rud.setting.a", "first attribute"))
  expect_equal(get_xattr(tf, "is.rud.setting.a"), "first attribute")
  
  # TO BE implemented with handle_user_prefix_{param,return}
  expect_equal(get_xattr_size(tf, "user.is.rud.setting.a"), 15L)

  # continue testing
  expect_equal(length(list_xattrs(tf)), 2)
  expect_equal(nrow(get_xattr_df(tf)), 2)
  expect_true(rm_xattr(tf, "is.rud.setting.a"))
  expect_equal(get_xattr(tf, "is.rud.setting.a"), character(0))

  unlink(tf)

})
