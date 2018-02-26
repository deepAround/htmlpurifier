<?php
namespace HTMLPurifier\AttrDef\Css;

use HTMLPurifier\Length;

/**
 * Represents a Length as defined by CSS.
 */
class AttrDefCSSLength extends \HTMLPurifier\AttrDef
{

    /**
     * @type Length|string
     */
    protected $min;

    /**
     * @type Length|string
     */
    protected $max;

    /**
     * @param Length|string $min Minimum length, or null for no bound. String is also acceptable.
     * @param Length|string $max Maximum length, or null for no bound. String is also acceptable.
     */
    public function __construct($min = null, $max = null)
    {
        $this->min = $min !== null ? Length::make($min) : null;
        $this->max = $max !== null ? Length::make($max) : null;
    }

    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate($string, $config, $context)
    {
        $string = $this->parseCDATA($string);

        // Optimizations
        if ($string === '') {
            return false;
        }
        if ($string === '0') {
            return '0';
        }
        if (strlen($string) === 1) {
            return false;
        }

        $length = Length::make($string);
        if (!$length->isValid()) {
            return false;
        }

        if ($this->min) {
            $c = $length->compareTo($this->min);
            if ($c === false) {
                return false;
            }
            if ($c < 0) {
                return false;
            }
        }
        if ($this->max) {
            $c = $length->compareTo($this->max);
            if ($c === false) {
                return false;
            }
            if ($c > 0) {
                return false;
            }
        }
        return $length->toString();
    }
}

// vim: et sw=4 sts=4
