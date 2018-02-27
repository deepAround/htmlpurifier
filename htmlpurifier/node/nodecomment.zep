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
    
    public function toTokenPair()
    {
        var tmpArray4a1f5ee48a0a26b566700b0f9a786dce;
    
        let tmpArray4a1f5ee48a0a26b566700b0f9a786dce = [new TokenComment(this->data, this->line, this->col), null];
        return tmpArray4a1f5ee48a0a26b566700b0f9a786dce;
    }

}