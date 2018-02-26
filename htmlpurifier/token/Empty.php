<?php
namespace HTMLPurifier\Token;

/**
 * Concrete empty token class.
 */
class TokenEmpty extends TokenTag
{
    public function toNode() {
        $n = parent::toNode();
        $n->empty = true;
        return $n;
    }
}

// vim: et sw=4 sts=4
