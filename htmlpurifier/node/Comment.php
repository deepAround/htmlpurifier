<?php
namespace HTMLPurifier\Node;

use HTMLPurifier\Token\TokenComment;

/**
 * Concrete comment node class.
 */
class NodeComment extends \HTMLPurifier\Node
{
    /**
     * Character data within comment.
     * @type string
     */
    public $data;

    /**
     * @type bool
     */
    public $is_whitespace = true;

    /**
     * Transparent constructor.
     *
     * @param string $data String comment data.
     * @param int $line
     * @param int $col
     */
    public function __construct($data, $line = null, $col = null)
    {
        $this->data = $data;
        $this->line = $line;
        $this->col = $col;
    }

    public function toTokenPair() {
        return array(new TokenComment($this->data, $this->line, $this->col), null);
    }
}
