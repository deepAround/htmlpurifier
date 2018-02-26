<?php

namespace HTMLPurifier\AttrTransform;

use HTMLPurifier\AttrDef\Html\AttrDefHTMLPixels;

/**
 * Performs miscellaneous cross attribute validation and filtering for
 * input elements. This is meant to be a post-transform.
 */
class AttrTransformInput extends \HTMLPurifier\AttrTransform
{
    /**
     * @type AttrDef_HTML_Pixels
     */
    protected $pixels;

    public function __construct()
    {
        $this->pixels = new AttrDefHTMLPixels();
    }

    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform($attr, $config, $context)
    {
        if (!isset($attr['type'])) {
            $t = 'text';
        } else {
            $t = strtolower($attr['type']);
        }
        if (isset($attr['checked']) && $t !== 'radio' && $t !== 'checkbox') {
            unset($attr['checked']);
        }
        if (isset($attr['maxlength']) && $t !== 'text' && $t !== 'password') {
            unset($attr['maxlength']);
        }
        if (isset($attr['size']) && $t !== 'text' && $t !== 'password') {
            $result = $this->pixels->validate($attr['size'], $config, $context);
            if ($result === false) {
                unset($attr['size']);
            } else {
                $attr['size'] = $result;
            }
        }
        if (isset($attr['src']) && $t !== 'image') {
            unset($attr['src']);
        }
        if (!isset($attr['value']) && ($t === 'radio' || $t === 'checkbox')) {
            $attr['value'] = '';
        }
        return $attr;
    }
}

// vim: et sw=4 sts=4
