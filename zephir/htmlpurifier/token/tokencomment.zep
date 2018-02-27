namespace HTMLPurifier\Token;

use HTMLPurifier\Node\NodeComment;
/**
 * Concrete comment token class. Generally will be ignored.
 */
class TokenComment extends \HTMLPurifier\Token
{
    /**
     * Character data within comment.
     * @type string
     */
    public data;
    /**
     * @type bool
     */
    public is_whitespace = true;
    /**
     * Transparent constructor.
     *
     * @param string $data String comment data.
     * @param int $line
     * @param int $col
     */
    public function __construct(string data, int line = null, int col = null) -> void
    {
        let this->data = data;
        let this->line = line;
        let this->col = col;
    }
    
    public function toNode()
    {
        return new NodeComment(this->data, this->line, this->col);
    }

}