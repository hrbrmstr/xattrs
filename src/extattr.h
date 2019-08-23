/*
  Filename: extattr.h
	Simple routines for dealing with extended attributes on OS X and FreeBSD
  https://github.com/bfoz/pocket/blob/3978b7461cf5f46ce394adc6b7000c17f96af639/extattr.h
	Created June 19, 2005 Brandon Fosdick
*/

#ifndef	XATTR_H
#define	XATTR_H

#if defined(__APPLE__) && defined(__MACH__)
#include <sys/xattr.h>
#endif

#if defined(__linux__)
/*
#include <sys/types.h>
*/
#include <attr/xattr.h>
#endif

#if defined(__FreeBSD__)
#include <sys/extattr.h>
#endif

#include <algorithm>
#include <vector>

typedef	std::pair<std::string, std::string>	ext_attr_t;
typedef	std::vector<std::string>	attr_names_t;
typedef	std::vector<ext_attr_t>	ext_attrs_t;

/*
inline int setxattr(int fd, const std::string &name, const std::string &value, int options=0)
{
#if defined(__APPLE__) && defined(__MACH__)
	return fsetxattr(fd, name.c_str(), value.data(), value.length(), 0, options);
#endif
#if defined(__linux__)
	return fsetxattr(fd, name.c_str(), value.data(), value.length(), 0);
#endif
#if defined(__FreeBSD__)
	return extattr_set_fd(fd, EXTATTR_NAMESPACE_USER, name.c_str(), value.data(), value.length());
#endif
}
*/

inline int setxattr(const std::string path, const std::string &name, const std::string &value, int options=0)
{
#if defined(__APPLE__) && defined(__MACH__)
	return setxattr(path.c_str(), name.c_str(), value.data(), value.length(), 0, options);
#endif
#if defined(__linux__)
  /* By default (i.e., options flags is zero), the extended attribute will be
   * created if it does not exist, or the value will be replaced if the attribute exists.*/
  if (options == 0){
    return setxattr(path.c_str(), name.c_str(), value.data(), value.length(), 0);
  } else {
    return lsetxattr(path.c_str(), name.c_str(), value.data(), value.length(), 0);
  }
#endif
#if defined(__FreeBSD__)
	return extattr_set_file(path.c_str(), EXTATTR_NAMESPACE_USER, name.c_str(), value.data(), value.length());
#endif
}


inline ssize_t getxattrsize(const std::string path, const std::string &name, int options=0)
{
#if defined(__APPLE__) && defined(__MACH__)
	return getxattr(path.c_str(), name.c_str(), NULL, 0, 0, options);
#endif
#if defined(__linux__)
  if (options == 0){
    return getxattr(path.c_str(), name.c_str(), NULL, 0);
  } else{
    return lgetxattr(path.c_str(), name.c_str(), NULL, 0);
  }
#endif
#if defined(__FreeBSD__)
	return extattr_get_file(path.c_str(), EXTATTR_NAMESPACE_USER, name.c_str(), NULL, 0);
#endif
}

inline std::string getxattr(const std::string path, const std::string &name, int options=0)
{
	ssize_t size = getxattrsize(path, name, options);
	char *buf;

	if( size <= 0 )
		return "";

	buf = new char[size];

#if defined(__APPLE__) && defined(__MACH__)
	getxattr(path.c_str(), name.c_str(), buf, size, 0, options);
#endif
#if defined(__linux__)
	if (options == 0){
	  getxattr(path.c_str(), name.c_str(), buf, size);
	} else{
	  lgetxattr(path.c_str(), name.c_str(), buf, size);
	}
#endif
#if defined(__FreeBSD__)
	extattr_get_file(path.c_str(), EXTATTR_NAMESPACE_USER, name.c_str(), buf, size);
#endif

	return std::string(buf, size);
}

//	*****	List attributes

//	Return the size of the list of extended attributes
inline ssize_t listxattrsize(const std::string path, int options=0)
{
#if defined(__APPLE__) && defined(__MACH__)
	return listxattr(path.c_str(), NULL, 0, options);
#endif
#if defined(__linux__)
  if (options == 0){
    return listxattr(path.c_str(), NULL, 0);
  } else{
    return llistxattr(path.c_str(), NULL, 0);
  }
#endif
#if defined(__FreeBSD__)
	return extattr_list_file(path.c_str(), EXTATTR_NAMESPACE_USER, NULL, 0);
#endif
}

//Read the extended attributes into one long string
//	***	The FreeBSD version returns an array of [length, data]
//	***	The OS X Tiger version returns an array of null terminated strings
inline size_t _listxattr(const std::string path, char *buf, const size_t size, int options=0)
{
#if defined(__APPLE__) && defined(__MACH__)
	return listxattr(path.c_str(), buf, size, options);
#endif
#if defined(__linux__)
  if (options == 0){
    return listxattr(path.c_str(), buf, size);
  } else{
    return llistxattr(path.c_str(), buf, size);
  }
#endif
#if defined(__FreeBSD__)
	return extattr_list_file(path.c_str(), EXTATTR_NAMESPACE_USER, buf, size);
#endif
}

#define	MIN(a,b)	((a<b)?a:b)

#if defined(__FreeBSD__)
//Return a list of attributes in a container, one attribute per element
inline attr_names_t listxattr(const std::string path, int options=0)
{
	ssize_t size = listxattrsize(path, options);
	char *buf;
	int i=0;
	int s;
	attr_names_t v;

//	std::cout << "0list size = " << size << std::endl;

	if( size <= 0 )
		return v;

	buf = new char[size];
	_listxattr(path, buf, size);

	while(i<size)
	{
		s = buf[i];	//Get the string size
//		std::cout << "string size = " << s << std::endl;
		++i;
		v.push_back(std::string(&(buf[i]), s));
		i += s;
	}

	return v;
}

//Return a list of attributes in a container, one attribute per element
//	Only return the elements that begin with prefix
inline attr_names_t listxattr(const std::string path, const std::string &prefix, int options=0)
{
	ssize_t size = listxattrsize(path, options);
	char *buf;
	ssize_t i=0;
	int s;
	attr_names_t v;

//	std::cout << "1list size = " << size << std::endl;
	if( size <= 0 )
		return v;

	buf = new char[size];

	_listxattr(path, buf, size);

	while(i<size)
	{
		s = buf[i];	//Get the string size
//		std::cout << "string size = " << s << std::endl;
		++i;
		if( memcmp(&(buf[i]), prefix.data(), MIN(s, prefix.length())) == 0)
			v.push_back(std::string(&(buf[i]), s));
		i += s;
	}

	return v;
}

#endif

#if defined(__APPLE__) && defined(__MACH__)
//Return a list of attributes in a container, one attribute per element
inline attr_names_t listxattr(const std::string path, int options=0)
{
	ssize_t size = listxattrsize(path, options);
	char *buf;
	ssize_t i=0;
	attr_names_t v;

	if( size <= 0 )
		return v;

	buf = new char[size];

	_listxattr(path, buf, size, options);

	while(i<size)
	{
		v.push_back(std::string(&(buf[i])));
		i += (v.back()).length() + 1;
	}
	return v;
}

//Return a list of attributes in a container, one attribute per element
//	Only return the elements that begin with prefix
inline attr_names_t listxattr(const std::string path, const std::string &prefix, int options=0)
{
	ssize_t size = listxattrsize(path, options);
	char *buf;
//	char *p;
	ssize_t i=0;
	int s;
	attr_names_t v;
	int j=0;

	if( size <= 0 )
		return v;

	buf = new char[size];

	_listxattr(path, buf, size, options);

//	p = buf;
	while(i<size)
	{
/*		s = strlen(p);
		if( strncmp(p, prefix.data(), MIN(s, prefix.length())) == 0)
		{
			v.push_back(std::string(p, s));
		++j;
		}
		p += s + 1;
		i += s + 1;
*/
		s = strlen(&(buf[i]));
		if( strncmp(&(buf[i]), prefix.data(), MIN(s, prefix.length())) == 0)
		{
			v.push_back(std::string(&(buf[i])));
		++j;
		}
		i += s + 1;
	}
	return v;
}

#endif

#if defined(__linux__)
//Return a list of attributes in a container, one attribute per element
inline attr_names_t listxattr(const std::string path, int options=0)
{
	ssize_t size = listxattrsize(path, options);
	char *buf;
	ssize_t i=0;
	attr_names_t v;

	if( size <= 0 )
		return v;

	buf = new char[size];

	_listxattr(path, buf, size, options);

	while(i<size)
	{
		v.push_back(std::string(&(buf[i])));
		i += (v.back()).length() + 1;
	}
	return v;
}

//Return a list of attributes in a container, one attribute per element
//	Only return the elements that begin with prefix
inline attr_names_t listxattr(const std::string path, const std::string &prefix, int options=0)
{
	ssize_t size = listxattrsize(path, options);
	char *buf;
//	char *p;
	ssize_t i=0;
	int s;
	attr_names_t v;
	int j=0;

	if( size <= 0 )
		return v;

	buf = new char[size];

	_listxattr(path, buf, size, options);

//	p = buf;
	while(i<size)
	{
/*		s = strlen(p);
		if( strncmp(p, prefix.data(), MIN(s, prefix.length())) == 0)
		{
			v.push_back(std::string(p, s));
		++j;
		}
		p += s + 1;
		i += s + 1;
*/
		s = strlen(&(buf[i]));
		if( strncmp(&(buf[i]), prefix.data(), MIN(s, prefix.length())) == 0)
		{
			v.push_back(std::string(&(buf[i])));
		++j;
		}
		i += s + 1;
	}
	return v;
}

#endif

/*
//Return a list of attributes in a container, one attribute per element
//	Only return the elements that begin with prefix
inline attr_names_t listxattr(const std::string path, const std::string &prefix, int options=0)
{
	std::istringstream S;
	std::string a;
	attr_names_t v;

	S.str(_listxattr(path, options, size));
	while(S)
	{
		getline(S, a);
		if( search(a.begin(), a.end(), prefix.begin(), prefix.end()) == prefix.begin() );
			v.push_back(a);
	}
	return v;
}
*/

//Remove the specified attribute
inline int removexattr(const std::string path, const std::string name, int options=0)
{
#if defined(__APPLE__) && defined(__MACH__)
	return removexattr(path.c_str(), name.c_str(), options);
#endif
#if defined(__linux__)
  if (options == 0){
    return removexattr(path.c_str(), name.c_str());
  } else{
    return lremovexattr(path.c_str(), name.c_str());
  }
#endif
#if defined(__FreeBSD__)
	return extattr_delete_file(path.c_str(), EXTATTR_NAMESPACE_USER, name.c_str());
#endif
}

//Remove all XA
inline bool removexattr(const std::string path, int options=0)
{
	attr_names_t names = listxattr(path);

	if(names.size() == 0)
		return false;

	for(attr_names_t::iterator i = names.begin(); i != names.end(); ++i )
	{
		removexattr(path, (*i));
	}
	return true;
}

//Remove all XA that begin with prefix
inline bool remove_xattr(const std::string path, const std::string &prefix, int options=0)
{
	attr_names_t names = listxattr(path, prefix);

	if(names.size() == 0)
		return false;

	for(attr_names_t::iterator i = names.begin(); i != names.end(); ++i )
	{
		removexattr(path, (*i));
	}
	return true;
}


// -----
inline ext_attrs_t getxattrs(const std::string path, const std::string &prefix, int options=0)
{
	attr_names_t names = listxattr(path, prefix);
	std::string s;
	ext_attrs_t	attrs;
	// int j = 0;

//	std::cout << " names.size => " << names.size() << std::endl;
	for(attr_names_t::iterator i = names.begin(); i != names.end(); ++i)
	{
		s = getxattr(path, (*i));
//		std::cout << (*i) << " => " << s << std::endl;
		attrs.push_back(ext_attr_t((*i), s));
	}

	return attrs;
}


#endif
