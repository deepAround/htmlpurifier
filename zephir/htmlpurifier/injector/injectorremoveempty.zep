namespace HTMLPurifier\Injector;

use HTMLPurifier\AttrValidator;
use HTMLPurifier\Injector;
use HTMLPurifier\Token\TokenEnd;
use HTMLPurifier\Token\TokenStart;
use HTMLPurifier\Token\TokenText;
class InjectorRemoveEmpty extends Injector
{
    /**
     * @type Context
     */
    protected context;
    /**
     * @type Config
     */
    protected config;
    /**
     * @type AttrValidator
     */
    protected attrValidator;
    /**
     * @type bool
     */
    protected removeNbsp;
    /**
     * @type bool
     */
    protected removeNbspExceptions;
    /**
     * Cached contents of %AutoFormat.RemoveEmpty.Predicate
     * @type array
     */
    protected exclude;
    /**
     * @param Config $config
     * @param Context $context
     * @return void
     */
    public function prepare(<Config> config, <Context> context)
    {
        var key, attrs;
    
        parent::prepare(config, context);
        let this->config = config;
        let this->context = context;
        let this->removeNbsp =  config->get("AutoFormat.RemoveEmpty.RemoveNbsp");
        let this->removeNbspExceptions =  config->get("AutoFormat.RemoveEmpty.RemoveNbsp.Exceptions");
        let this->exclude =  config->get("AutoFormat.RemoveEmpty.Predicate");
        for key, attrs in this->exclude {
            if !(is_array(attrs)) {
                // HACK, see HTMLPurifier/Printer/ConfigForm.php
                let this->exclude[key] =  explode(";", attrs);
            }
        }
        let this->attrValidator =  new AttrValidator();
    }
    
    /**
     * @param Token $token
     */
    public function handleElement(<Token> token)
    {
        var next, deleted, i, plain, isWsOrNbsp, r, elem, b, c, prev;
    
        if !(token instanceof TokenStart) {
            return;
        }
        let next =  false;
        let deleted = 1;
        // the current tag
        let i =  count(this->inputZipper->back) - 1;
        for i in range(count(this->inputZipper->back) - 1, 0) {
            let next = this->inputZipper->back[i];
            if next instanceof TokenText {
                if next->is_whitespace {
                    continue;
                }
                if this->removeNbsp && !(isset this->removeNbspExceptions[token->name]) {
                    let plain =  str_replace(" ", "", next->data);
                    let isWsOrNbsp =  plain === "" || ctype_space(plain);
                    if isWsOrNbsp {
                        continue;
                    }
                }
            }
            break;
        }
        if !(next) || next instanceof TokenEnd && next->name == token->name {
            this->attrValidator->validateToken(token, this->config, this->context);
            let token->armor["ValidateAttributes"] = true;
            if isset this->exclude[token->name] {
                let r =  true;
                for elem in this->exclude[token->name] {
                    if !(isset token->attr[elem]) {
                        let r =  false;
                    }
                }
                if r {
                    return;
                }
            }
            if isset token->attr["id"] || isset token->attr["name"] {
                return;
            }
            let token =  deleted + 1;
            let b = 0;
            let c =  count(this->inputZipper->front);
            for b in range(0, c) {
                let prev = this->inputZipper->front[b];
                if prev instanceof TokenText && prev->is_whitespace {
                    continue;
                }
                break;
            }
            // This is safe because we removed the token that triggered this.
            this->rewindOffset(b + deleted);
            return;
        }
    }

}