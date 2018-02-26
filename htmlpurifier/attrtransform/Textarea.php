<?php

namespace HTMLPurifier\AttrTransform;

/**
 * Sets height/width defaults for <textarea>
 */
class AttrTransformTextarea extends \HTMLPurifier\AttrTransform
{
    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform($attr, $config, $context)
    {
        // Calculated from Firefox
        if (!isset($attr['cols'])) {
            $attr['cols'] = '22';
        }
        if (!isset($attr['rows'])) {
            $attr['rows'] = '3';
        }
        return $attr;
    }
}

// vim: et sw=4 sts=4
