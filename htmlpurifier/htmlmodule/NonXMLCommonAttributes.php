<?php
namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;

class HTMLModuleNonXMLCommonAttributes extends HTMLModule
{
    /**
     * @type string
     */
    public $name = 'NonXMLCommonAttributes';

    /**
     * @type array
     */
    public $attr_collections = array(
        'Lang' => array(
            'lang' => 'LanguageCode',
        )
    );
}

// vim: et sw=4 sts=4
