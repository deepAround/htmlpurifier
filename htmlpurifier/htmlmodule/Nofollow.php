<?php
namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\AttrTransform\AttrTransformNofollow;

/**
 * Module adds the nofollow attribute transformation to a tags.  It
 * is enabled by HTML.Nofollow
 */
class HTMLModuleNofollow extends HTMLModule
{

    /**
     * @type string
     */
    public $name = 'Nofollow';

    /**
     * @param Config $config
     */
    public function setup($config)
    {
        $a = $this->addBlankElement('a');
        $a->attr_transform_post[] = new AttrTransformNofollow();
    }
}

// vim: et sw=4 sts=4
