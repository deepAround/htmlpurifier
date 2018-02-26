<?php
namespace HTMLPurifier\HTMLModule\Tidy;

use HTMLPurifier\AttrTransform\AttrTransformBackground;
use HTMLPurifier\AttrTransform\AttrTransformLength;
use HTMLPurifier\HTMLModule\HTMLModuleTidy;

class HTMLModuleTidy_Proprietary extends HTMLModuleTidy
{

    /**
     * @type string
     */
    public $name = 'Tidy_Proprietary';

    /**
     * @type string
     */
    public $defaultLevel = 'light';

    /**
     * @return array
     */
    public function makeFixes()
    {
        $r = array();
        $r['table@background'] = new AttrTransformBackground();
        $r['td@background']    = new AttrTransformBackground();
        $r['th@background']    = new AttrTransformBackground();
        $r['tr@background']    = new AttrTransformBackground();
        $r['thead@background'] = new AttrTransformBackground();
        $r['tfoot@background'] = new AttrTransformBackground();
        $r['tbody@background'] = new AttrTransformBackground();
        $r['table@height']     = new AttrTransformLength('height');
        return $r;
    }
}

// vim: et sw=4 sts=4
