# Create a temp file for the example
tf <- tempfile(fileext = ".csv")
write.csv(mtcars, tf)

# has attributes? (shld be FALSE)
has_xattrs(tf)
get_xattr(tf, "is.rud.setting")

# set an attribute
set_xattr(tf, "is.rud.setting.a", "first attribut")
get_xattr(tf, "is.rud.setting.a")
get_xattr_size(tf, "is.rud.setting.a")

# shld be TRUE
has_xattrs(tf)

set_xattr(tf, "is.rud.setting.b", "second attribute")
get_xattr(tf, "is.rud.setting.b")
get_xattr_size(tf, "is.rud.setting.b")

# overwrite an attribute
set_xattr(tf, "is.rud.setting.a", "first attribute")
get_xattr(tf, "is.rud.setting.a")
get_xattr_size(tf, "is.rud.setting.a")

# see all the attributes
list_xattrs(tf)

# data frame vs individual functions
get_xattr_df(tf)

# remove attribute
rm_xattr(tf, "is.rud.setting")
get_xattr(tf, "is.rud.setting")

# cleanup
unlink(tf)

