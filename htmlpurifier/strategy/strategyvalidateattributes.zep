namespace HTMLPurifier\Strategy;

use HTMLPurifier\AttrValidator;
use HTMLPurifier\Token\TokenEmpty;
use HTMLPurifier\Token\TokenStart;
/**
 * Validate all attributes in the tokens.
 */
class StrategyValidateAttributes extends \HTMLPurifier\Strategy
{
    /**
     * @param Token[] $tokens
     * @param Config $config
     * @param Context $context
     * @return Token[]
     */
    public function execute(array tokens, <Config> config, <Context> context) -> array
    {
        var validator, token, key;
    
        // setup validator
        let validator =  new AttrValidator();
        let token =  false;
        context->register("CurrentToken", token);
        for key, token in tokens {
            // only process tokens that have attributes,
            //   namely start and empty tags
            if !(token instanceof TokenStart) && !(token instanceof TokenEmpty) {
                continue;
            }
            // skip tokens that are armored
            if !(empty(token->armor["ValidateAttributes"])) {
                continue;
            }
            // note that we have no facilities here for removing tokens
            validator->validateToken(token, config, context);
        }
        context->destroy("CurrentToken");
        return tokens;
    }

}