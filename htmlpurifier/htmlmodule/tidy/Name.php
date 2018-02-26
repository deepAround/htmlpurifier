<?php
namespace HTMLPurifier\HTMLModule\Tidy;

use HTMLPurifier\AttrTransform\AttrTransformName;
use HTMLPurifier\HTMLModule\HTMLModuleTidy;

/**
 * Name is deprecated, but allowed in strict doctypes, so onl
 */
class HTMLModuleTidyName extends HTMLModuleTidy
{
    /**
     * @type string
     */
    public $name = 'Tidy_Name';

    /**
     * @type string
     */
    public $defaultLevel = 'heavy';

    /**
     * @return array
     */
    public function makeFixes()
    {
        $r = array();
        // @name for img, a -----------------------------------------------
        // Technically, it's allowed even on strict, so we allow authors to use
        // it. However, it's deprecated in future versions of XHTML.
        $r['img@name'] =
        $r['a@name'] = new AttrTransformName();
        return $r;
    }
}

// vim: et sw=4 sts=4
