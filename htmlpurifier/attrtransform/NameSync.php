<?php

namespace HTMLPurifier\AttrTransform;

use HTMLPurifier\AttrDef\Html\AttrDefHTMLID;

/**
 * Post-transform that performs validation to the name attribute; if
 * it is present with an equivalent id attribute, it is passed through;
 * otherwise validation is performed.
 */
class AttrTransformNameSync extends \HTMLPurifier\AttrTransform
{

    public function __construct()
    {
        $this->idDef = new AttrDefHTMLID();
    }

    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform($attr, $config, $context)
    {
        if (!isset($attr['name'])) {
            return $attr;
        }
        $name = $attr['name'];
        if (isset($attr['id']) && $attr['id'] === $name) {
            return $attr;
        }
        $result = $this->idDef->validate($name, $config, $context);
        if ($result === false) {
            unset($attr['name']);
        } else {
            $attr['name'] = $result;
        }
        return $attr;
    }
}

// vim: et sw=4 sts=4
