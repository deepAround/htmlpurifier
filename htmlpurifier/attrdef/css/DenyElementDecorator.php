<?php
namespace HTMLPurifier\AttrDef\Css;

/**
 * Decorator which enables CSS properties to be disabled for specific elements.
 */
class AttrDefCSSDenyElementDecorator extends \HTMLPurifier\AttrDef
{
    /**
     * @type AttrDef
     */
    public $def;
    /**
     * @type string
     */
    public $element;

    /**
     * @param AttrDef $def Definition to wrap
     * @param string $element Element to deny
     */
    public function __construct($def, $element)
    {
        $this->def = $def;
        $this->element = $element;
    }

    /**
     * Checks if CurrentToken is set and equal to $this->element
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate($string, $config, $context)
    {
        $token = $context->get('CurrentToken', true);
        if ($token && $token->name == $this->element) {
            return false;
        }
        return $this->def->validate($string, $config, $context);
    }
}

// vim: et sw=4 sts=4
