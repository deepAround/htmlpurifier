<?php
namespace HTMLPurifier\URIScheme;

/**
 * Validates https (Secure HTTP) according to http scheme.
 */
class URISchemeHttps extends URISchemeHttp
{
    /**
     * @type int
     */
    public $default_port = 443;
    /**
     * @type bool
     */
    public $secure = true;
}

// vim: et sw=4 sts=4
