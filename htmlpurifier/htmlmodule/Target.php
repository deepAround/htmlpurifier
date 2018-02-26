<?php
namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\AttrDef\Html\AttrDefHTMLFrameTarget;

/**
 * XHTML 1.1 Target Module, defines target attribute in link elements.
 */
class HTMLModuleTarget extends HTMLModule
{
    /**
     * @type string
     */
    public $name = 'Target';

    /**
     * @param Config $config
     */
    public function setup($config)
    {
        $elements = array('a');
        foreach ($elements as $name) {
            $e = $this->addBlankElement($name);
            $e->attr = array(
                'target' => new AttrDefHTMLFrameTarget()
            );
        }
    }
}

// vim: et sw=4 sts=4
