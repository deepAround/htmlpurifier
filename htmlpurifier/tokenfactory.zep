namespace HTMLPurifier;

use HTMLPurifier\Token\TokenComment;
use HTMLPurifier\Token\TokenEmpty;
use HTMLPurifier\Token\TokenEnd;
use HTMLPurifier\Token\TokenStart;
use HTMLPurifier\Token\TokenText;
/**
 * Factory for token generation.
 *
 * @note Doing some benchmarking indicates that the new operator is much
 *       slower than the clone operator (even discounting the cost of the
 *       constructor).  This class is for that optimization.
 *       Other then that, there's not much point as we don't
 *       maintain parallel Token hierarchies (the main reason why
 *       you'd want to use an abstract factory).
 * @todo Port DirectLex to use this
 */
class TokenFactory
{
    // p stands for prototype
    /**
     * @type TokenStart
     */
    protected p_start;
    /**
     * @type TokenEnd
     */
    protected p_end;
    /**
     * @type TokenEmpty
     */
    protected p_empty;
    /**
     * @type TokenText
     */
    protected p_text;
    /**
     * @type TokenComment
     */
    protected p_comment;
    /**
     * Generates blank prototypes for cloning.
     */
    public function __construct() -> void
    {
        var tmpArray40cd750bba9870f18aada2478b24840a;
    
        let this->p_start =  new TokenStart("", []);
        let this->p_end =  new TokenEnd("");
        let this->p_empty =  new TokenEmpty("", []);
        let this->p_text =  new TokenText("");
        let this->p_comment =  new TokenComment("");
    }
    
    /**
     * Creates a TokenStart.
     * @param string $name Tag name
     * @param array $attr Associative array of attributes
     * @return TokenStart Generated TokenStart
     */
    public function createStart(string name, array attr = []) -> <TokenStart>
    {
        var p;
    
        let p =  clone this->p_start;
        p->__construct(name, attr);
        return p;
    }
    
    /**
     * Creates a TokenEnd.
     * @param string $name Tag name
     * @return TokenEnd Generated TokenEnd
     */
    public function createEnd(string name) -> <TokenEnd>
    {
        var p;
    
        let p =  clone this->p_end;
        p->__construct(name);
        return p;
    }
    
    /**
     * Creates a TokenEmpty.
     * @param string $name Tag name
     * @param array $attr Associative array of attributes
     * @return TokenEmpty Generated TokenEmpty
     */
    public function createEmpty(string name, array attr = []) -> <TokenEmpty>
    {
        var p;
    
        let p =  clone this->p_empty;
        p->__construct(name, attr);
        return p;
    }
    
    /**
     * Creates a TokenText.
     * @param string $data Data of text token
     * @return TokenText Generated TokenText
     */
    public function createText(string data) -> <TokenText>
    {
        var p;
    
        let p =  clone this->p_text;
        p->__construct(data);
        return p;
    }
    
    /**
     * Creates a TokenComment.
     * @param string $data Data of comment token
     * @return TokenComment Generated TokenComment
     */
    public function createComment(string data) -> <TokenComment>
    {
        var p;
    
        let p =  clone this->p_comment;
        p->__construct(data);
        return p;
    }

}