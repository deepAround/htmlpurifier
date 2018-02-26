<?php
namespace HTMLPurifier\AttrDef\Css;

/**
 * Validates a Percentage as defined by the CSS spec.
 */
class AttrDefCSSPercentage extends \HTMLPurifier\AttrDef
{

    /**
     * Instance to defer number validation to.
     * @type AttrDefCSSNumber
     */
    protected $number_def;

    /**
     * @param bool $non_negative Whether to forbid negative values
     */
    public function __construct($non_negative = false)
    {
        $this->number_def = new AttrDefCSSNumber($non_negative);
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

        if ($string === '') {
            return false;
        }
        $length = strlen($string);
        if ($length === 1) {
            return false;
        }
        if ($string[$length - 1] !== '%') {
            return false;
        }

        $number = substr($string, 0, $length - 1);
        $number = $this->number_def->validate($number, $config, $context);

        if ($number === false) {
            return false;
        }
        return "$number%";
    }
}

// vim: et sw=4 sts=4
