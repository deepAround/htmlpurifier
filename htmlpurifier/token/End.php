<?php
namespace HTMLPurifier\Token;

use HTMLPurifier\Exception;

/**
 * Concrete end token class.
 *
 * @warning This class accepts attributes even though end tags cannot. This
 * is for optimization reasons, as under normal circumstances, the Lexers
 * do not pass attributes.
 */
class TokenEnd extends TokenTag
{
    /**
     * Token that started this node.
     * Added by MakeWellFormed. Please do not edit this!
     * @type Token
     */
    public $start;

    public function toNode() {
    		throw new Exception("TokenEnd->toNode not supported!");
    }
}

// vim: et sw=4 sts=4
