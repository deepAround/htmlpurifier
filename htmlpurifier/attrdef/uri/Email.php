<?php
namespace HTMLPurifier\AttrDef\Uri;

abstract class AttrDefURIEmail extends \HTMLPurifier\AttrDef
{

    /**
     * Unpacks a mailbox into its display-name and address
     * @param string $string
     * @return mixed
     */
    public function unpack($string)
    {
        // needs to be implemented
    }

}

// sub-implementations

// vim: et sw=4 sts=4
