HTML Purifier [![Build Status](https://secure.travis-ci.org/ezyang/htmlpurifier.svg?branch=master)](http://travis-ci.org/ezyang/htmlpurifier)
=============

HTML Purifier is an HTML filtering solution that uses a unique combination
of robust whitelists and aggressive parsing to ensure that not only are
XSS attacks thwarted, but the resulting HTML is standards compliant.

HTML Purifier is oriented towards richly formatted documents from
untrusted sources that require CSS and a full tag-set.  This library can
be configured to accept a more restrictive set of tags, but it won't be
as efficient as more bare-bones parsers. It will, however, do the job
right, which may be more important.



## Installation

If you're using zephir, you can use

    $ git clone https://github.com/deepAround/htmlpurifier
    $ cd htmlpurifier
    $ zephir build
