namespace HTMLPurifier\Injector;

use HTMLPurifier\Injector;
use HTMLPurifier\Token\TokenText;
/**
 * Injector that displays the URL of an anchor instead of linking to it, in addition to showing the text of the link.
 */
class InjectorDisplayLinkURI extends Injector
{
    /**
     * @type string
     */
    public name = "DisplayLinkURI";
    /**
     * @type array
     */
    public needed = ["a"];
    /**
     * @param $token
     */
    public function handleElement(token) -> void
    {
    }
    
    /**
     * @param Token $token
     */
    public function handleEnd(<Token> token) -> void
    {
        var url;
    
        if isset token->start->attr["href"] {
            let url = token->start->attr["href"];
            unset token->start->attr["href"];
            
            let token =  [token, new TokenText(" ({url})")];
        } else {
        }
    }

}