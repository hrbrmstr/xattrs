#include <Rcpp.h>
#include <algorithm>
#include <sys/stat.h>

#if defined(__linux__)
// #include <attr/xattr.h>
#define XATTR_NOFOLLOW 0x0001 /* Don't follow symbolic links */
#endif

#include "extattr.h"

using namespace Rcpp;

//' Test if a target path has xattrs
//'
//' @md
//' @param path target path (file or dir); this is auto-expanded
//' @param follow_symlinks if `FALSE` get xattr of the symlink vs the target it references
//' @export
//' @example inst/examples/ex1.R
// [[Rcpp::export]]
bool has_xattrs(const std::string path, bool follow_symlinks=true) {
  std::string full_path = std::string(R_ExpandFileName(path.c_str()));
  int options = 0;
  if (!follow_symlinks) options = XATTR_NOFOLLOW;
  return(listxattrsize(full_path, options) > 0);
}

inline RawVector getxattr_raw(const std::string path, const std::string &name, int options=0) {

  ssize_t size = getxattrsize(path, name, options);
  uint8_t *buf;

  if (size <= 0) return RawVector::create();

  buf = new uint8_t[size];

#if defined(__APPLE__) && defined(__MACH__)
  getxattr(path.c_str(), name.c_str(), buf, size, 0, options);
#endif
#if defined(__linux__)
  getxattr(path.c_str(), name.c_str(), buf, size);
#endif
#if defined(__FreeBSD__)
  extattr_get_file(path.c_str(), EXTATTR_NAMESPACE_USER, name.c_str(), buf, size);
#endif

  RawVector out(&buf[0], &buf[0] + size);

  return(out);

}

inline int setxattr_raw(const std::string path, const std::string &name, RawVector value, int options=0) {
#if defined(__APPLE__) && defined(__MACH__)
  return setxattr(path.c_str(), name.c_str(), value.begin(), value.size(), 0, options);
#endif
#if defined(__linux__)
  return setxattr(path.c_str(), name.c_str(), value.begin(), value.size(), options);
#endif
#if defined(__FreeBSD__)
  return extattr_set_file(path.c_str(), EXTATTR_NAMESPACE_USER, name.c_str(), value.begin(), value.size());
#endif
}

// [[Rcpp::export]]
int rcpp_set_xattr(std::string path, std::string name, RawVector value, bool follow_symlinks=true) {
  int options = 0;
  if (!follow_symlinks) options = XATTR_NOFOLLOW;
  return(setxattr_raw(path, name, value, options));
}

// [[Rcpp::export]]
int rcpp_rm_xattr(std::string path, std::string name, bool follow_symlinks=true) {
  int options = 0;
  if (!follow_symlinks) options = XATTR_NOFOLLOW;
#if defined(__APPLE__) && defined(__MACH__)
  return(removexattr(path, name, options));
#endif
#if defined(__linux__)
  return(removexattr(path.c_str(), name.c_str()));
#endif
#if defined(__FreeBSD__)
  return(removexattr(path, name, options));
#endif

}

// [[Rcpp::export]]
CharacterVector rcpp_list_xattrs(const std::string path, bool follow_symlinks=true) {
  std::string full_path = std::string(R_ExpandFileName(path.c_str()));
  int options = 0;
  if (!follow_symlinks) options = XATTR_NOFOLLOW;
  if (has_xattrs(full_path, follow_symlinks)) {
    return(Rcpp::wrap(listxattr(full_path, options)));
  }
  return(CharacterVector::create());
}

// [[Rcpp::export]]
CharacterVector rcpp_get_xattr(const std::string path, std::string name, bool follow_symlinks=true) {
  std::string full_path = std::string(R_ExpandFileName(path.c_str()));
  int options = 0;
  if (!follow_symlinks) options = XATTR_NOFOLLOW;
  if (has_xattrs(full_path, follow_symlinks)) {
    std::string out = getxattr(full_path, name, options);
    if (out.length()>0) return(Rcpp::wrap(out));
  }
  return(CharacterVector::create());
}

// [[Rcpp::export]]
RawVector rcpp_get_xattr_raw(const std::string path, std::string name, bool follow_symlinks=true) {
  std::string full_path = std::string(R_ExpandFileName(path.c_str()));
  int options = 0;
  if (!follow_symlinks) options = XATTR_NOFOLLOW;
  if (has_xattrs(full_path, follow_symlinks)) {
    RawVector out = getxattr_raw(full_path, name, options);
    if (out.length() > 0) return(out);
  }
  return(RawVector::create());
}

// [[Rcpp::export]]
ssize_t rcpp_get_xattr_size(const std::string path, std::string name, bool follow_symlinks=true) {
  std::string full_path = std::string(R_ExpandFileName(path.c_str()));
  int options = 0;
  if (!follow_symlinks) options = XATTR_NOFOLLOW;
  if (has_xattrs(full_path, follow_symlinks)) {
    ssize_t sz = getxattrsize(full_path, name, options);
    if (sz > 0) return(sz);
  }
  return(0);
}

// [[Rcpp::export]]
List rcpp_get_xattr_df(const std::string path, bool follow_symlinks=true) {

  std::string full_path = std::string(R_ExpandFileName(path.c_str()));

  int options = 0;
  if (!follow_symlinks) options = XATTR_NOFOLLOW;

  std::vector<std::string> xnames = listxattr(full_path, options);
  std::vector<ssize_t> sz(xnames.size());
  std::vector<RawVector> contents(xnames.size());

  for (R_xlen_t i=0; i<xnames.size(); i++) {
    sz[i] = getxattrsize(full_path, xnames[i], options);
    contents[i] = RawVector(getxattr_raw(full_path, xnames[i], options));
  }

  List xdf = List::create(
    _["name"] = xnames,
    _["size"] = sz,
    _["contents"] = contents
  );

  return(xdf);

}
