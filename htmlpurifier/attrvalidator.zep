namespace HTMLPurifier;

use HTMLPurifier\Token\TokenEmpty;
use HTMLPurifier\Token\TokenStart;
/**
 * Validates the attributes of a token. Doesn't manage required attributes
 * very well. The only reason we factored this out was because RemoveForeignElements
 * also needed it besides ValidateAttributes.
 */
class AttrValidator
{
    /**
     * Validates the attributes of a token, mutating it as necessary.
     * that has valid tokens
     * @param Token $token Token to validate.
     * @param Config $config Instance of Config
     * @param Context $context Instance of Context
     */
    public function validateToken(<Token> token, <Config> config, <Context> context)
    {
        var definition, id_accumulator, d_defs, attr, transform, o, defs, attr_key, value, result;
    
        let definition =  config->getHTMLDefinition();
        let e = context->get("ErrorCollector", true);
        // initialize IDAccumulator if necessary
        let ok = context->get("IDAccumulator", true);
        if !(ok) {
            let id_accumulator =  IDAccumulator::build(config, context);
            context->register("IDAccumulator", id_accumulator);
        }
        // initialize CurrentToken if necessary
        let current_token = context->get("CurrentToken", true);
        if !(current_token) {
            context->register("CurrentToken", token);
        }
        if !(token instanceof TokenStart) && !(token instanceof TokenEmpty) {
            return;
        }
        // create alias to global definition array, see also $defs
        // DEFINITION CALL
        let d_defs =  definition->info_global_attr;
        // don't update token until the very end, to ensure an atomic update
        let attr =  token->attr;
        // do global transformations (pre)
        // nothing currently utilizes this
        for transform in definition->info_attr_transform_pre {
            let o = attr;
            let attr =  transform->transform(o, config, context);
            if e {
                if attr != o {
                    e->send(E_NOTICE, "AttrValidator: Attributes transformed", o, attr);
                }
            }
        }
        // do local transformations only applicable to this element (pre)
        // ex. <p align="right"> to <p style="text-align:right;">
        for transform in definition->info[token->name]->attr_transform_pre {
            let o = attr;
            let attr =  transform->transform(o, config, context);
            if e {
                if attr != o {
                    e->send(E_NOTICE, "AttrValidator: Attributes transformed", o, attr);
                }
            }
        }
        // create alias to this element's attribute definition array, see
        // also $d_defs (global attribute definition array)
        // DEFINITION CALL
        let defs =  definition->info[token->name]->attr;
        let attr_key =  false;
        context->register("CurrentAttr", attr_key);
        // iterate through all the attribute keypairs
        // Watch out for name collisions: $key has previously been used
        for attr_key, value in attr {
            // call the definition
            if isset defs[attr_key] {
                // there is a local definition defined
                if defs[attr_key] === false {
                    // We've explicitly been told not to allow this element.
                    // This is usually when there's a global definition
                    // that must be overridden.
                    // Theoretically speaking, we could have a
                    // AttrDef_DenyAll, but this is faster!
                    let result =  false;
                } else {
                    // validate according to the element's definition
                    let result =  defs[attr_key]->validate(value, config, context);
                }
            } elseif isset d_defs[attr_key] {
                // there is a global definition defined, validate according
                // to the global definition
                let result =  d_defs[attr_key]->validate(value, config, context);
            } else {
                // system never heard of the attribute? DELETE!
                let result =  false;
            }
            // put the results into effect
            if result === false || result === null {
                // this is a generic error message that should replaced
                // with more specific ones when possible
                if e {
                    e->send(E_ERROR, "AttrValidator: Attribute removed");
                }
                // remove the attribute
                unset attr[attr_key];
            
            } elseif is_string(result) {
                // generally, if a substitution is happening, there
                // was some sort of implicit correction going on. We'll
                // delegate it to the attribute classes to say exactly what.
                // simple substitution
                let attr[attr_key] = result;
            } else {
            }
        }
        context->destroy("CurrentAttr");
        // post transforms
        // global (error reporting untested)
        for transform in definition->info_attr_transform_post {
            let o = attr;
            let attr =  transform->transform(o, config, context);
            if e {
                if attr != o {
                    e->send(E_NOTICE, "AttrValidator: Attributes transformed", o, attr);
                }
            }
        }
        // local (error reporting untested)
        for transform in definition->info[token->name]->attr_transform_post {
            let o = attr;
            let attr =  transform->transform(o, config, context);
            if e {
                if attr != o {
                    e->send(E_NOTICE, "AttrValidator: Attributes transformed", o, attr);
                }
            }
        }
        let token->attr = attr;
        // destroy CurrentToken if we made it ourselves
        if !(current_token) {
            context->destroy("CurrentToken");
        }
    }

}