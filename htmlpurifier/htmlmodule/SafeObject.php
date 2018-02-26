<?php
namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\AttrDef\AttrDefEnum;
use HTMLPurifier\AttrTransform\AttrTransformSafeObject;
use HTMLPurifier\AttrTransform\AttrTransformSafeParam;

/**
 * A "safe" object module. In theory, objects permitted by this module will
 * be safe, and untrusted users can be allowed to embed arbitrary flash objects
 * (maybe other types too, but only Flash is supported as of right now).
 * Highly experimental.
 */
class HTMLModuleSafeObject extends HTMLModule
{
    /**
     * @type string
     */
    public $name = 'SafeObject';

    /**
     * @param Config $config
     */
    public function setup($config)
    {
        // These definitions are not intrinsically safe: the attribute transforms
        // are a vital part of ensuring safety.

        $max = $config->get('HTML.MaxImgLength');
        $object = $this->addElement(
            'object',
            'Inline',
            'Optional: param | Flow | #PCDATA',
            'Common',
            array(
                // While technically not required by the spec, we're forcing
                // it to this value.
                'type' => 'Enum#application/x-shockwave-flash',
                'width' => 'Pixels#' . $max,
                'height' => 'Pixels#' . $max,
                'data' => 'URI#embedded',
                'codebase' => new AttrDefEnum(
                    array(
                        'http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0'
                    )
                ),
            )
        );
        $object->attr_transform_post[] = new AttrTransformSafeObject();

        $param = $this->addElement(
            'param',
            false,
            'Empty',
            false,
            array(
                'id' => 'ID',
                'name*' => 'Text',
                'value' => 'Text'
            )
        );
        $param->attr_transform_post[] = new AttrTransformSafeParam();
        $this->info_injector[] = 'SafeObject';
    }
}

// vim: et sw=4 sts=4
