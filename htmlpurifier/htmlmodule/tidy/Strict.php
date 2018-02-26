<?php
namespace HTMLPurifier\HTMLModule\Tidy;

use HTMLPurifier\ChildDef\ChildDefStrictBlockquote;

class HTMLModuleTidyStrict extends HTMLModuleTidyXHTMLAndHTML4
{
    /**
     * @type string
     */
    public $name = 'Tidy_Strict';

    /**
     * @type string
     */
    public $defaultLevel = 'light';

    /**
     * @return array
     */
    public function makeFixes()
    {
        $r = parent::makeFixes();
        $r['blockquote#content_model_type'] = 'strictblockquote';
        return $r;
    }

    /**
     * @type bool
     */
    public $defines_child_def = true;

    /**
     * @param ElementDef $def
     * @return ChildDefStrictBlockquote
     */
    public function getChildDef($def)
    {
        if ($def->content_model_type != 'strictblockquote') {
            return parent::getChildDef($def);
        }
        return new ChildDefStrictBlockquote($def->content_model);
    }
}

// vim: et sw=4 sts=4
