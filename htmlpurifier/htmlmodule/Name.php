<?php
namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\AttrTransform\AttrTransformNameSync;

class HTMLModuleName extends HTMLModule
{
    /**
     * @type string
     */
    public $name = 'Name';

    /**
     * @param Config $config
     */
    public function setup($config)
    {
        $elements = array('a', 'applet', 'form', 'frame', 'iframe', 'img', 'map');
        foreach ($elements as $name) {
            $element = $this->addBlankElement($name);
            $element->attr['name'] = 'CDATA';
            if (!$config->get('HTML.Attr.Name.UseCDATA')) {
                $element->attr_transform_post[] = new AttrTransformNameSync();
            }
        }
    }
}

// vim: et sw=4 sts=4
