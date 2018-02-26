<?php

namespace HTMLPurifier\AttrTransform;

class AttrTransformSafeEmbed extends \HTMLPurifier\AttrTransform
{
    /**
     * @type string
     */
    public $name = "SafeEmbed";

    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform($attr, $config, $context)
    {
        $attr['allowscriptaccess'] = 'never';
        $attr['allownetworking'] = 'internal';
        $attr['type'] = 'application/x-shockwave-flash';
        return $attr;
    }
}

// vim: et sw=4 sts=4
