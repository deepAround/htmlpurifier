namespace HTMLPurifier\Injector;

use HTMLPurifier\Injector;
use HTMLPurifier\Token\TokenEmpty;
/**
 * Adds important param elements to inside of object in order to make
 * things safe.
 */
class InjectorSafeObject extends Injector
{
    /**
     * @type string
     */
    public name = "SafeObject";
    /**
     * @type array
     */
    public needed = ["object", "param"];
    /**
     * @type array
     */
    protected objectStack = [];
    /**
     * @type array
     */
    protected paramStack = [];
    /**
     * Keep this synchronized with AttrTransform/SafeParam.php.
     * @type array
     */
    protected addParam = ["allowScriptAccess" : "never", "allowNetworking" : "internal"];
    /**
     * These are all lower-case keys.
     * @type array
     */
    protected allowedParam = ["wmode" : true, "movie" : true, "flashvars" : true, "src" : true, "allowfullscreen" : true];
    /**
     * @param Config $config
     * @param Context $context
     * @return void
     */
    public function prepare(<Config> config, <Context> context)
    {
        parent::prepare(config, context);
    }
    
    /**
     * @param Token $token
     */
    public function handleElement(<Token> token)
    {
        var new, name, value, tmpArray0b0b22ccfe191f45e47dd17e4c273d4a, nest, i, n;
    
        if token->name == "object" {
            let this->objectStack[] = token;
            let this->paramStack[] =  [];
            let new =  [token];
            for name, value in this->addParam {
                let new[] = new TokenEmpty("param", ["name" : name, "value" : value]);
            }
            let token = new;
        } elseif token->name == "param" {
            let nest =  count(this->currentNesting) - 1;
            if nest >= 0 && this->currentNesting[nest]->name === "object" {
                let i =  count(this->objectStack) - 1;
                if !(isset token->attr["name"]) {
                    let token =  false;
                    return;
                }
                let n = token->attr["name"];
                // We need this fix because YouTube doesn't supply a data
                // attribute, which we need if a type is specified. This is
                // *very* Flash specific.
                if !(isset this->objectStack[i]->attr["data"]) && (token->attr["name"] == "movie" || token->attr["name"] == "src") {
                    let this->objectStack[i]->attr["data"] = token->attr["value"];
                }
                // Check if the parameter is the correct value but has not
                // already been added
                if !(isset this->paramStack[i][n]) && isset this->addParam[n] && token->attr["name"] === this->addParam[n] {
                    // keep token, and add to param stack
                    let this->paramStack[i][n] = true;
                } elseif isset this->allowedParam[strtolower(n)] {
                } else {
                    let token =  false;
                }
            } else {
                // not directly inside an object, DENY!
                let token =  false;
            }
        }
    }
    
    public function handleEnd(token) -> void
    {
        // This is the WRONG way of handling the object and param stacks;
        // we should be inserting them directly on the relevant object tokens
        // so that the global stack handling handles it.
        if token->name == "object" {
            array_pop(this->objectStack);
            array_pop(this->paramStack);
        }
    }

}