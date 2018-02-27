namespace HTMLPurifier\Node;

use HTMLPurifier\Token\TokenEmpty;
use HTMLPurifier\Token\TokenEnd;
use HTMLPurifier\Token\TokenStart;
/**
 * Concrete element node class.
 */
class NodeElement extends \HTMLPurifier\Node
{
    /**
     * The lower-case name of the tag, like 'a', 'b' or 'blockquote'.
     *
     * @note Strictly speaking, XML tags are case sensitive, so we shouldn't
     * be lower-casing them, but these tokens cater to HTML tags, which are
     * insensitive.
     * @type string
     */
    public name;
    /**
     * Associative array of the node's attributes.
     * @type array
     */
    public attr = [];
    /**
     * List of child elements.
     * @type array
     */
    public children = [];
    /**
     * Does this use the <a></a> form or the </a> form, i.e.
     * is it a pair of start/end tokens or an empty token.
     * @bool
     */
    public empty = false;
    public endCol = null, endLine = null, endArmor = [];
    public function __construct(name, attr = [], line = null, col = null, armor = []) -> void
    {
        let this->name = name;
        let this->attr = attr;
        let this->line = line;
        let this->col = col;
        let this->armor = armor;
    }
    
    public function toTokenPair()
    {
        var tmpArray111ff5a755556121e4793ec8f4a8ed36, start, end, tmpArray40cd750bba9870f18aada2478b24840a, tmpArrayef755cf551126411e2cdec6bf4f96990;
    
        // XXX inefficiency here, normalization is not necessary
        if this->empty {
            let tmpArray111ff5a755556121e4793ec8f4a8ed36 = [new TokenEmpty(this->name, this->attr, this->line, this->col, this->armor), null];
            return tmpArray111ff5a755556121e4793ec8f4a8ed36;
        } else {
            let start =  new TokenStart(this->name, this->attr, this->line, this->col, this->armor);
            let end =  new TokenEnd(this->name, [], this->endLine, this->endCol, this->endArmor);
            //$end->start = $start;
            let tmpArrayef755cf551126411e2cdec6bf4f96990 = [start, end];
            return tmpArrayef755cf551126411e2cdec6bf4f96990;
        }
    }

}