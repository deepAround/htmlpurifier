<?php
namespace HTMLPurifier\URIScheme;

use HTMLPurifier\URIScheme;

/**
 * Validates news (Usenet) as defined by generic RFC 1738
 */
class URISchemeNews extends URIScheme
{
    /**
     * @type bool
     */
    public $browsable = false;

    /**
     * @type bool
     */
    public $may_omit_host = true;

    /**
     * @param URI $uri
     * @param Config $config
     * @param Context $context
     * @return bool
     */
    public function doValidate(&$uri, $config, $context)
    {
        $uri->userinfo = null;
        $uri->host = null;
        $uri->port = null;
        $uri->query = null;
        // typecode check needed on path
        return true;
    }
}

// vim: et sw=4 sts=4
