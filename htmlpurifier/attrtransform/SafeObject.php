<?php

namespace HTMLPurifier\AttrTransform;

/**
 * Writes default type for all objects. Currently only supports flash.
 */
class AttrTransformSafeObject extends \HTMLPurifier\AttrTransform
{
    /**
     * @type string
     */
    public $name = "SafeObject";

    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform($attr, $config, $context)
    {
        if (!isset($attr['type'])) {
            $attr['type'] = 'application/x-shockwave-flash';
        }
        return $attr;
    }
}

// vim: et sw=4 sts=4
