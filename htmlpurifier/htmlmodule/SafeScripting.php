<?php
namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\AttrDef\AttrDefEnum;
use HTMLPurifier\AttrTransform\AttrTransformScriptRequired;

/**
 * A "safe" script module. No inline JS is allowed, and pointed to JS
 * files must match whitelist.
 */
class HTMLModuleSafeScripting extends HTMLModule
{
    /**
     * @type string
     */
    public $name = 'SafeScripting';

    /**
     * @param Config $config
     */
    public function setup($config)
    {
        // These definitions are not intrinsically safe: the attribute transforms
        // are a vital part of ensuring safety.

        $allowed = $config->get('HTML.SafeScripting');
        $script = $this->addElement(
            'script',
            'Inline',
            'Empty',
            null,
            array(
                // While technically not required by the spec, we're forcing
                // it to this value.
                'type' => 'Enum#text/javascript',
                'src*' => new AttrDefEnum(array_keys($allowed))
            )
        );
        $script->attr_transform_pre[] =
        $script->attr_transform_post[] = new AttrTransformScriptRequired();
    }
}

// vim: et sw=4 sts=4
