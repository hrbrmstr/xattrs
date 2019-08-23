
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Signed
by](https://img.shields.io/badge/Keybase-Verified-brightgreen.svg)](https://keybase.io/hrbrmstr)
![Signed commit
%](https://img.shields.io/badge/Signed_Commits-100%25-lightgrey.svg)
[![Linux build
Status](https://travis-ci.org/hrbrmstr/xattrs.svg?branch=master)](https://travis-ci.org/hrbrmstr/xattrs)
[![Coverage
Status](https://codecov.io/gh/hrbrmstr/xattrs/branch/master/graph/badge.svg)](https://codecov.io/gh/hrbrmstr/xattrs)
![Minimal R
Version](https://img.shields.io/badge/R%3E%3D-3.2.0-blue.svg)
![License](https://img.shields.io/badge/License-MIT-blue.svg)

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

  - `get_xattr_df`: Retrieve a data frame of xattr names, sizes and
    (raw) contents for a target path
  - `get_xattr_raw`: Get raw contents of an extended attribute
  - `get_xattr_size`: Get size of an extended attribute
  - `get_xattr`: Get an extended attribute
  - `handle_user_prefix_param`: handle\_user\_prefix\_param
  - `handle_user_prefix_return`: handle\_user\_prefix\_return
  - `has_xattrs`: Test if a target path has xattrs
  - `is_bplist`: Tests whether a raw vector is really a binary plist
  - `list_xattrs`: List attributes
  - `read_bplist`: Convert binary plist to something usable in R
  - `rm_xattr`: Remove an extended attribute
  - `set_xattr`: Set or modify an extended attribute

## Installation

``` r
install.packages("xattrs", repos = "https://cinc.rud.is")
# or
remotes::install_git("https://git.rud.is/hrbrmstr/xattrs.git")
# or
remotes::install_git("https://git.sr.ht/~hrbrmstr/xattrs")
# or
remotes::install_gitlab("hrbrmstr/xattrs")
# or
remotes::install_bitbucket("hrbrmstr/xattrs")
# or
remotes::install_github("hrbrmstr/xattrs")
```

NOTE: To use the ‘remotes’ install options you will need to have the
[{remotes} package](https://github.com/r-lib/remotes) installed.

## Usage

``` r
library(xattrs)
library(tidyverse) # for printing

# current verison
packageVersion("xattrs")
## [1] '0.1.1'
```

### Basic Operation

Extended attributes seem to get stripped when R builds pkgs so until I
can figure out an easy way not to do that, just find any file on your
system that has an `@` next to the permissions string in an `ls -l`
directory listing.

``` r
sample_file <- "~/Downloads/AdvancedTechniquesWithAWSGlueETLJobs.pdf"

list_xattrs(sample_file)
## [1] "com.apple.metadata:kMDItemWhereFroms"
## [2] "com.apple.quarantine"  

get_xattr_size(sample_file, "com.apple.metadata:kMDItemWhereFroms")
## 157
```

Extended attributes can be *anything* so it makes alot of sense to work
with the contents as a raw vector:

``` r
get_xattr_raw(sample_file, "com.apple.metadata:kMDItemWhereFroms")
##   [1] 62 70 6c 69 73 74 30 30 a2 01 02 5f 10 6b 68 74 74 70 73 3a 2f
##  [22] 2f 66 69 6c 65 73 2e 73 6c 61 63 6b 2e 63 6f 6d 2f 66 69 6c 65
##  [43] 73 2d 70 72 69 2f 54 33 56 31 5a 44 51 48 4d 2d 46 44 4a 47 59
##  [64] 4b 57 4a 33 2f 64 6f 77 6e 6c 6f 61 64 2f 61 64 76 61 6e 63 65
##  [85] 64 74 65 63 68 6e 69 71 75 65 73 77 69 74 68 61 77 73 67 6c 75
## [106] 65 65 74 6c 6a 6f 62 73 5f 5f 31 5f 2e 70 64 66 50 08 0b 79 00
## [127] 00 00 00 00 00 01 01 00 00 00 00 00 00 00 03 00 00 00 00 00 00
## [148] 00 00 00 00 00 00 00 00 00 7a
```

There is a “string” version of the function, but it may return “nothing”
if there are embedded NULLs or other breaking characters in the
contents:

``` r
get_xattr(sample_file, "com.apple.metadata:kMDItemWhereFroms")
## [1] "bplist00\xa2\001\002_\020khttps://files.slack.com/files-pri/T3V1ZDQHM-FDJGYKWJ3/download/advancedtechniqueswithawsglueetljobs__1_.pdfP\b\vy"
```

You are really better off doing this if you really want a raw string
conversion:

``` r
readBin(get_xattr_raw(sample_file, "com.apple.metadata:kMDItemWhereFroms"), "character")
## [1] "bplist00\xa2\001\002_\020khttps://files.slack.com/files-pri/T3V1ZDQHM-FDJGYKWJ3/download/advancedtechniqueswithawsglueetljobs__1_.pdfP\b\vy"
```

More often than not (on macOS) extended attributes are “binary property
lists” (or “binary plist” for short). You can test to see if the
returned raw vector is likely a binary plist:

``` r
is_bplist(get_xattr_raw(sample_file, "com.apple.metadata:kMDItemWhereFroms"))
## [1] TRUE
```

If it is, you can get the data out of it. For now, this makes a system
call to `plutil` on macOS and `plistutil` on other systems. You’ll be
given a hint on how to install `plistutil` if it’s not found.

``` r
read_bplist(get_xattr_raw(sample_file, "com.apple.metadata:kMDItemWhereFroms"))
## $plist
## $plist$array
## $plist$array$string
## $plist$array$string[[1]]
## [1] "https://files.slack.com/files-pri/T3V1ZDQHM-FDJGYKWJ3/download/advancedtechniqueswithawsglueetljobs__1_.pdf"
## 
## 
## $plist$array$string
## list()
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
## 1 com.apple.metadata:kMDItemWhereFroms   157 <raw [157]>
## 2 com.apple.quarantine                    56 <raw [56]> 
```

you can live dangerously even with data frames, tho:

``` r
get_xattr_df(sample_file) %>% 
  mutate(txt = map_chr(contents, readBin, "character")) # potentially "dangerous"
## # A tibble: 2 x 4
##   name                 size contents  txt                            
##   <chr>               <dbl> <list>    <chr>                          
## 1 com.apple.metadata…   157 <raw [15… "bplist00\xa2\x01\x02_\x10khtt…
## 2 com.apple.quaranti…    56 <raw [56… 0083;5bc9c8ca;Slack;44698902-A…
```

### Extended Example

We can process a whole directory of files to see what extended
attributes various path targets have:

``` r
fils <- list.files("~/Downloads", full.names = TRUE) 

xdf <- map_df(set_names(fils, fils), get_xattr_df, .id="path")

count(xdf, name, sort=TRUE) 
## # A tibble: 11 x 2
##    name                                                     n
##    <chr>                                                <int>
##  1 com.apple.quarantine                                    55
##  2 com.apple.metadata:kMDItemWhereFroms                    46
##  3 com.apple.lastuseddate#PS                               13
##  4 com.apple.metadata:_kMDItemUserTags                      3
##  5 com.apple.metadata:kMDItemDownloadedDate                 2
##  6 com.apple.diskimages.fsck                                1
##  7 com.apple.diskimages.recentcksum                         1
##  8 com.apple.FinderInfo                                     1
##  9 com.apple.metadata:com_apple_mail_dateReceived           1
## 10 com.apple.metadata:com_apple_mail_dateSent               1
## 11 com.apple.metadata:com_apple_mail_isRemoteAttachment     1
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
## # A tibble: 44 x 2
##     size converted                                              
##    <dbl> <chr>                                                  
##  1   189 dl.packetstormsecurity.net                             
##  2   129 files.slack.com                                        
##  3   120 files.slack.com                                        
##  4   117 files.slack.com                                        
##  5   592 irma.nps.gov                                           
##  6   157 files.slack.com                                        
##  7   624 github-production-release-asset-2e65be.s3.amazonaws.com
##  8   197 images.unsplash.com                                    
##  9   197 images.unsplash.com                                    
## 10   185 files.slack.com                                        
## # … with 34 more rows
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
```

<div class="kable-table">

| name             | size | contents                                                                                                  |
| :--------------- | ---: | :-------------------------------------------------------------------------------------------------------- |
| is.rud.setting.a |   15 | as.raw(c(0x66, 0x69, 0x72, 0x73, 0x74, 0x20, 0x61, 0x74, 0x74, 0x72, 0x69, 0x62, 0x75, 0x74, 0x65))       |
| is.rud.setting.b |   16 | as.raw(c(0x73, 0x65, 0x63, 0x6f, 0x6e, 0x64, 0x20, 0x61, 0x74, 0x74, 0x72, 0x69, 0x62, 0x75, 0x74, 0x65)) |

</div>

``` r

# remove attribute
rm_xattr(tf, "is.rud.setting")
get_xattr(tf, "is.rud.setting")
## character(0)

# cleanup
unlink(tf)
```

## xattrs Metrics

| Lang         | \# Files |  (%) | LoC |  (%) | Blank lines |  (%) | \# Lines |  (%) |
| :----------- | -------: | ---: | --: | ---: | ----------: | ---: | -------: | ---: |
| C/C++ Header |        1 | 0.06 | 283 | 0.35 |          69 | 0.29 |       90 | 0.22 |
| R            |       13 | 0.76 | 240 | 0.30 |          85 | 0.35 |      158 | 0.38 |
| C++          |        2 | 0.12 | 228 | 0.28 |          33 | 0.14 |       26 | 0.06 |
| Rmd          |        1 | 0.06 |  49 | 0.06 |          54 | 0.22 |      138 | 0.33 |

## Code of Conduct

Please note that this project is released with a Contributor Code of
Conduct. By participating in this project you agree to abide by its
terms.
