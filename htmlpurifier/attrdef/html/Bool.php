<?php
namespace HTMLPurifier\AttrDef\Html;

/**
 * Validates a boolean attribute
 */
class AttrDefHTMLBool extends \HTMLPurifier\AttrDef
{

    /**
     * @type bool
     */
    protected $name;

    /**
     * @type bool
     */
    public $minimized = true;

    /**
     * @param bool $name
     */
    public function __construct($name = false)
    {
        $this->name = $name;
    }

    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate($string, $config, $context)
    {
        return $this->name;
    }

    /**
     * @param string $string Name of attribute
     * @return AttrDefHTMLBool
     */
    public function make($string)
    {
        return new AttrDefHTMLBool($string);
    }
}

// vim: et sw=4 sts=4
