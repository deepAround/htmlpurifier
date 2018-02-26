<?php
namespace HTMLPurifier\AttrDef;

/**
 * Dummy AttrDef that mimics another AttrDef, BUT it generates clones
 * with make.
 */
class AttrDefClone extends \HTMLPurifier\AttrDef
{
    /**
     * What we're cloning.
     * @type AttrDef
     */
    protected $clone;

    /**
     * @param AttrDef $clone
     */
    public function __construct($clone)
    {
        $this->clone = $clone;
    }

    /**
     * @param string $v
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate($v, $config, $context)
    {
        return $this->clone->validate($v, $config, $context);
    }

    /**
     * @param string $string
     * @return AttrDef
     */
    public function make($string)
    {
        return clone $this->clone;
    }
}

// vim: et sw=4 sts=4
