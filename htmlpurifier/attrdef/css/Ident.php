<?php
namespace HTMLPurifier\AttrDef\Css;

/**
 * Validates based on {ident} CSS grammar production
 */
class AttrDefCSSIdent extends \HTMLPurifier\AttrDef
{

    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate($string, $config, $context)
    {
        $string = trim($string);

        // early abort: '' and '0' (strings that convert to false) are invalid
        if (!$string) {
            return false;
        }

        $pattern = '/^(-?[A-Za-z_][A-Za-z_\-0-9]*)$/';
        if (!preg_match($pattern, $string)) {
            return false;
        }
        return $string;
    }
}

// vim: et sw=4 sts=4
