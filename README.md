
<!-- README.md is generated from README.Rmd. Please edit that file -->

# xattrs

Work With Filesystem Object Extended Attributes

## Description

Filesystem path target extended attributes store extra, customizable,
small bits of info. For example, author name, file character encoding,
short comments, security status, etc. Methods are provided to list,
extract and work with these attributes.

## NOTE

I don’t think this will work on Windows.

## What’s Inside The Tin

The following functions are implemented:

  - `get_xattr`: Retrieve the contents of the named xattr
  - `get_xattr_df`: Retrieve a data frame of xattr names, sizes and
    (raw) contents for a target path
  - `get_xattr_raw`: Retrieve the (raw) contents of the named xattr
  - `get_xattr_size`: Retrieve the size (bytes) of the named xattr
  - `has_xattrs`: Test if a target path has xattrs
  - `is_bplist`: Tests whether a raw vector is really a binary plist
  - `list_xattrs`: List extended attribute names of a target path
  - `read_bplist`: Convert binary plist to something usable in R

## Installation

``` r
devtools::install_github("hrbrmstr/xattrs")
```

## Usage

``` r
library(xattrs)
library(tidyverse)

# current verison
packageVersion("xattrs")
## [1] '0.1.0'
```

### Basic Operation

Extended attributes seem to get stripped when R builds pkgs so until I
can figure out an easy way not to do that, just find any file on your
system that has an `@` next to the permissions string in an `ls -l`
directory listing.

``` r
sample_file <- "~/Downloads/Elementary-Lunch-Menu.pdf"

list_xattrs(sample_file)
## [1] "com.apple.metadata:kMDItemWhereFroms" "com.apple.quarantine"

get_xattr_size(sample_file, "com.apple.metadata:kMDItemWhereFroms")
## [1] 177
```

Extended attributes can be *anything* so it makes alot of sense to work
with the contents as a raw vector:

``` r
get_xattr_raw(sample_file, "com.apple.metadata:kMDItemWhereFroms")
##   [1] 62 70 6c 69 73 74 30 30 a2 01 02 5f 10 53 68 74 74 70 3a 2f 2f 77 77 77 2e 6d 73 61 64 36 30 2e 6f 72 67 2f 77 70
##  [39] 2d 63 6f 6e 74 65 6e 74 2f 75 70 6c 6f 61 64 73 2f 32 30 31 37 2f 30 31 2f 45 6c 65 6d 65 6e 74 61 72 79 2d 46 65
##  [77] 62 72 75 61 72 79 2d 4c 75 6e 63 68 2d 4d 65 6e 75 2e 70 64 66 5f 10 2a 68 74 74 70 3a 2f 2f 77 77 77 2e 6d 73 61
## [115] 64 36 30 2e 6f 72 67 2f 62 6c 6f 67 2f 66 65 62 72 75 61 72 79 2d 6d 65 6e 75 73 2f 08 0b 61 00 00 00 00 00 00 01
## [153] 01 00 00 00 00 00 00 00 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 8e
```

There is a “string” version of the function, but it may return “nothing”
if there are embedded NULLs or other breaking characters in the
contents:

``` r
get_xattr(sample_file, "com.apple.metadata:kMDItemWhereFroms")
## [1] "bplist00\xa2\001\002_\020Shttp://www.msad60.org/wp-content/uploads/2017/01/Elementary-February-Lunch-Menu.pdf_\020*http://www.msad60.org/blog/february-menus/\b\va"
```

You are really better off doing this if you really want a raw string
conversion:

``` r
readBin(get_xattr_raw(sample_file, "com.apple.metadata:kMDItemWhereFroms"), "character")
## [1] "bplist00\xa2\001\002_\020Shttp://www.msad60.org/wp-content/uploads/2017/01/Elementary-February-Lunch-Menu.pdf_\020*http://www.msad60.org/blog/february-menus/\b\va"
```

More often than not (on macOS) extended attributes are “binary property
lists” (or “binary plist” for short). You can test to see if the
returned raw vector is likely a binary
plist:

``` r
is_bplist(get_xattr_raw(sample_file, "com.apple.metadata:kMDItemWhereFroms"))
## [1] TRUE
```

If it is, you can get the data out of it. For now, this makes a system
call to `plutil` on macOS and `plistutil` on other systems. You’ll be
given a hint on how to install `plistutil` if it’s not
found.

``` r
read_bplist(get_xattr_raw(sample_file, "com.apple.metadata:kMDItemWhereFroms"))
## $plist
## $plist$array
## $plist$array$string
## $plist$array$string[[1]]
## [1] "http://www.msad60.org/wp-content/uploads/2017/01/Elementary-February-Lunch-Menu.pdf"
## 
## 
## $plist$array$string
## $plist$array$string[[1]]
## [1] "http://www.msad60.org/blog/february-menus/"
## 
## 
## 
## attr(,"version")
## [1] "1.0"
```

This is R, so you should really consider doing this instead of any of
the above \#rectanglesrule:

``` r
get_xattr_df(sample_file)
## # A tibble: 2 x 3
##   name                                  size contents   
##   <chr>                                <dbl> <list>     
## 1 com.apple.metadata:kMDItemWhereFroms  177. <raw [177]>
## 2 com.apple.quarantine                   68. <raw [68]>
```

you can live dangerously even with data frames, tho:

``` r
get_xattr_df(sample_file) %>% 
  mutate(txt = map_chr(contents, readBin, "character")) # potentially "dangerous"
## # A tibble: 2 x 4
##   name                                  size contents    txt                                                           
##   <chr>                                <dbl> <list>      <chr>                                                         
## 1 com.apple.metadata:kMDItemWhereFroms  177. <raw [177]> "bplist00\xa2\x01\x02_\x10Shttp://www.msad60.org/wp-content/u…
## 2 com.apple.quarantine                   68. <raw [68]>  0083;5891d3e4;Google Chrome.app;FF4E968A-9E06-4C79-B4CA-C6A31…
```

### Extended Example

We can process a whole directory of files to see what extended
attributes various path targets have:

``` r
fils <- list.files("~/Downloads", full.names = TRUE) 

xdf <- map_df(set_names(fils, fils), get_xattr_df, .id="path")

count(xdf, name, sort=TRUE) 
## # A tibble: 4 x 2
##   name                                         n
##   <chr>                                    <int>
## 1 com.apple.quarantine                        28
## 2 com.apple.metadata:kMDItemWhereFroms        23
## 3 com.apple.metadata:_kMDItemUserTags          8
## 4 com.apple.metadata:kMDItemDownloadedDate     1
```

And we can work with `com.apple.metadata:kMDItemWhereFroms` binary plist
data in bulk:

``` r
filter(xdf, name == "com.apple.metadata:kMDItemWhereFroms") %>%
  filter(map_lgl(contents, is_bplist)) %>% 
  mutate(converted = map(contents, read_bplist)) %>% 
  select(size, converted) %>% 
  mutate(converted = map(converted, ~flatten_chr(.x$plist$array$string))) %>% 
  unnest() %>% 
  mutate(converted = urltools::domain(converted)) # you don't rly need to see the full URLs for this example
## # A tibble: 23 x 2
##     size converted                                                       
##    <dbl> <chr>                                                           
##  1  143. eprint.ncl.ac.uk                                                
##  2  117. files.slack.com                                                 
##  3  592. irma.nps.gov                                                    
##  4  110. apps.start.umd.edu                                              
##  5 1510. aws-athena-query-results-181646978271-us-east-1.s3.amazonaws.com
##  6  145. www.eac.gov                                                     
##  7  177. www.msad60.org                                                  
##  8  185. www.telerik.com                                                 
##  9  152. www.gess-inc.com                                                
## 10  134. files.slack.com                                                 
## # ... with 13 more rows
```

### Full Suite

``` r
# Create a temp file for the example
tf <- tempfile(fileext = ".csv")
write.csv(mtcars, tf)

# has attributes? (shld be FALSE)
has_xattrs(tf)
## [1] FALSE
get_xattr(tf, "is.rud.setting")
## character(0)

# set an attribute
set_xattr(tf, "is.rud.setting.a", "first attribut")
get_xattr(tf, "is.rud.setting.a")
## [1] "first attribut"
get_xattr_size(tf, "is.rud.setting.a")
## [1] 14

# shld be TRUE
has_xattrs(tf)
## [1] TRUE

set_xattr(tf, "is.rud.setting.b", "second attribute")
get_xattr(tf, "is.rud.setting.b")
## [1] "second attribute"
get_xattr_size(tf, "is.rud.setting.b")
## [1] 16

# overwrite an attribute
set_xattr(tf, "is.rud.setting.a", "first attribute")
get_xattr(tf, "is.rud.setting.a")
## [1] "first attribute"
get_xattr_size(tf, "is.rud.setting.a")
## [1] 15

# see all the attributes
list_xattrs(tf)
## [1] "is.rud.setting.a" "is.rud.setting.b"

# data frame vs individual functions
get_xattr_df(tf)
## # A tibble: 2 x 3
##   name              size contents  
##   <chr>            <dbl> <list>    
## 1 is.rud.setting.a   15. <raw [15]>
## 2 is.rud.setting.b   16. <raw [16]>

# remove attribute
rm_xattr(tf, "is.rud.setting")
get_xattr(tf, "is.rud.setting")
## character(0)

# cleanup
unlink(tf)
```

## Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.
