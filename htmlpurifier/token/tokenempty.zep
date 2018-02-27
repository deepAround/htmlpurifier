namespace HTMLPurifier\Token;

/**
 * Concrete empty token class.
 */
class TokenEmpty extends TokenTag
{
    public function toNode()
    {
        var n;
    
        let n =  parent::toNode();
        let n->empty =  true;
        return n;
    }

}