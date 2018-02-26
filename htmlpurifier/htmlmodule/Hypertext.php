<?php
namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\AttrDef\Html\AttrDefHTMLLinkTypes;

/**
 * XHTML 1.1 Hypertext Module, defines hypertext links. Core Module.
 */
class HTMLModuleHypertext extends HTMLModule
{

    /**
     * @type string
     */
    public $name = 'Hypertext';

    /**
     * @param Config $config
     */
    public function setup($config)
    {
        $a = $this->addElement(
            'a',
            'Inline',
            'Inline',
            'Common',
            array(
                // 'accesskey' => 'Character',
                // 'charset' => 'Charset',
                'href' => 'URI',
                // 'hreflang' => 'LanguageCode',
                'rel' => new AttrDefHTMLLinkTypes('rel'),
                'rev' => new AttrDefHTMLLinkTypes('rev'),
                // 'tabindex' => 'Number',
                // 'type' => 'ContentType',
            )
        );
        $a->formatting = true;
        $a->excludes = array('a' => true);
    }
}

// vim: et sw=4 sts=4
