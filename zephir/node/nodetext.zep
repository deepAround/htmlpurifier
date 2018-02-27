namespace HTMLPurifier\Node;

use HTMLPurifier\Token\TokenText;
/**
 * Concrete text token class.
 *
 * Text tokens comprise of regular parsed character data (PCDATA) and raw
 * character data (from the CDATA sections). Internally, their
 * data is parsed with all entities expanded. Surprisingly, the text token
 * does have a "tag name" called #PCDATA, which is how the DTD represents it
 * in permissible child nodes.
 */
class NodeText extends \HTMLPurifier\Node
{
    /**
     * PCDATA tag name compatible with DTD, see
     * ChildDef_Custom for details.
     * @type string
     */
    public name = "#PCDATA";
    /**
     * @type string
     */
    public data;
    /**< Parsed character data of text. */
    /**
     * @type bool
     */
    public is_whitespace;
    /**< Bool indicating if node is whitespace. */
    /**
     * Constructor, accepts data and determines if it is whitespace.
     * @param string $data String parsed character data.
     * @param int $line
     * @param int $col
     */
    public function __construct(data, is_whitespace, line = null, col = null) -> void
    {
        let this->data = data;
        let this->is_whitespace = is_whitespace;
        let this->line = line;
        let this->col = col;
    }
    
    public function toTokenPair()
    {
        var tmpArrayef3f2fa869aab7a793ca01000af6c828;
    
        let tmpArrayef3f2fa869aab7a793ca01000af6c828 = [new TokenText(this->data, this->line, this->col), null];
        return tmpArrayef3f2fa869aab7a793ca01000af6c828;
    }

}