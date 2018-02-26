<?php
namespace HTMLPurifier\HTMLModule\Tidy;

use HTMLPurifier\AttrTransform\AttrTransformLang;
use HTMLPurifier\HTMLModule\HTMLModuleTidy;

class HTMLModuleTidy_XHTML extends HTMLModuleTidy
{
    /**
     * @type string
     */
    public $name = 'Tidy_XHTML';

    /**
     * @type string
     */
    public $defaultLevel = 'medium';

    /**
     * @return array
     */
    public function makeFixes()
    {
        $r = array();
        $r['@lang'] = new AttrTransformLang();
        return $r;
    }
}

// vim: et sw=4 sts=4
