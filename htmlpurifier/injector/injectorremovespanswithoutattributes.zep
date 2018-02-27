namespace HTMLPurifier\Injector;

use HTMLPurifier\AttrValidator;
use HTMLPurifier\Injector;
use HTMLPurifier\Token\TokenEnd;
use HTMLPurifier\Token\TokenStart;
/**
 * Injector that removes spans with no attributes
 */
class InjectorRemoveSpansWithoutAttributes extends Injector
{
    /**
     * @type string
     */
    public name = "RemoveSpansWithoutAttributes";
    /**
     * @type array
     */
    public needed = ["span"];
    /**
     * @type AttrValidator
     */
    protected attrValidator;
    /**
     * Used by AttrValidator.
     * @type Config
     */
    protected config;
    /**
     * @type Context
     */
    protected context;
    public function prepare(config, context)
    {
        let this->attrValidator =  new AttrValidator();
        let this->config = config;
        let this->context = context;
        return parent::prepare(config, context);
    }
    
    /**
     * @param Token $token
     */
    public function handleElement(<Token> token)
    {
        var nesting;
    
        if token->name !== "span" || !(token instanceof TokenStart) {
            return;
        }
        // We need to validate the attributes now since this doesn't normally
        // happen until after MakeWellFormed. If all the attributes are removed
        // the span needs to be removed too.
        this->attrValidator->validateToken(token, this->config, this->context);
        let token->armor["ValidateAttributes"] = true;
        if !(empty(token->attr)) {
            return;
        }
        let nesting = 0;
        while (this->forwardUntilEndToken(i, current, nesting)) {
        }
        if current instanceof TokenEnd && current->name === "span" {
            // Mark closing span tag for deletion
            let current->markForDeletion =  true;
            // Delete open span tag
            let token =  false;
        }
    }
    
    /**
     * @param Token $token
     */
    public function handleEnd(<Token> token) -> void
    {
        if token->markForDeletion {
            let token =  false;
        }
    }

}