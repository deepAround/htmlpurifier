<?php
namespace HTMLPurifier\URIScheme;

use HTMLPurifier\URIScheme;

/**
 * Validates http (HyperText Transfer Protocol) as defined by RFC 2616
 */
class URISchemeHttp extends URIScheme
{
    /**
     * @type int
     */
    public $default_port = 80;

    /**
     * @type bool
     */
    public $browsable = true;

    /**
     * @type bool
     */
    public $hierarchical = true;

    /**
     * @param URI $uri
     * @param Config $config
     * @param Context $context
     * @return bool
     */
    public function doValidate(&$uri, $config, $context)
    {
        $uri->userinfo = null;
        return true;
    }
}

// vim: et sw=4 sts=4
