<?php
namespace HTMLPurifier\AttrDef;

/**
 * Validates arbitrary text according to the HTML spec.
 */
class AttrDefText extends \HTMLPurifier\AttrDef
{

    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate($string, $config, $context)
    {
        return $this->parseCDATA($string);
    }
}

// vim: et sw=4 sts=4
