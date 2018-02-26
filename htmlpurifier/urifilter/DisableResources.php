<?php
namespace HTMLPurifier\URIFilter;

use HTMLPurifier\URIFilter;

class URIFilterDisableResources extends URIFilter
{
    /**
     * @type string
     */
    public $name = 'DisableResources';

    /**
     * @param URI $uri
     * @param Config $config
     * @param Context $context
     * @return bool
     */
    public function filter(&$uri, $config, $context)
    {
        return !$context->get('EmbeddedURI', true);
    }
}

// vim: et sw=4 sts=4
