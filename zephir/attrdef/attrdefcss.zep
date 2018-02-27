namespace HTMLPurifier\AttrDef;

/**
 * Validates the HTML attribute style, otherwise known as CSS.
 * @note We don't implement the whole CSS specification, so it might be
 *       difficult to reuse this component in the context of validating
 *       actual stylesheet declarations.
 * @note If we were really serious about validating the CSS, we would
 *       tokenize the styles and then parse the tokens. Obviously, we
 *       are not doing that. Doing that could seriously harm performance,
 *       but would make these components a lot more viable for a CSS
 *       filtering solution.
 */
class AttrDefCSS extends \HTMLPurifier\AttrDef
{
    /**
     * @param string $css
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string css, <Config> config, <Context> context)
    {
        var definition, allow_duplicates, len, accum, declarations, quoted, i, c, d, propvalues, new_declarations, property, declaration, value, tmpListPropertyValue, ok, result, prop;
    
        let css =  this->parseCDATA(css);
        let definition =  config->getCSSDefinition();
        let allow_duplicates =  config->get("CSS.AllowDuplicates");
        // According to the CSS2.1 spec, the places where a
        // non-delimiting semicolon can appear are in strings
        // escape sequences.   So here is some dumb hack to
        // handle quotes.
        let len =  strlen(css);
        let accum = "";
        let declarations =  [];
        let quoted =  false;
        let i = 0;
        for i in range(0, len) {
            let c =  strcspn(css, ";'\"", i);
            let accum .= substr(css, i, c);
            let i += c;
            if i == len {
                break;
            }
            let d = css[i];
            if quoted {
                let accum .= d;
                if d == quoted {
                    let quoted =  false;
                }
            } else {
                if d == ";" {
                    let declarations[] = accum;
                    let accum = "";
                } else {
                    let accum .= d;
                    let quoted = d;
                }
            }
        }
        if accum != "" {
            let declarations[] = accum;
        }
        let propvalues =  [];
        let new_declarations = "";
        /**
         * Name of the current CSS property being validated.
         */
        let property =  false;
        context->register("CurrentCSSProperty", property);
        for declaration in declarations {
            if !(declaration) {
                continue;
            }
            if !(strpos(declaration, ":")) {
                continue;
            }
            let tmpListPropertyValue = explode(":", declaration, 2);
            let property = tmpListPropertyValue[0];
            let value = tmpListPropertyValue[1];
            let property =  trim(property);
            let value =  trim(value);
            let ok =  false;
            do {
                if isset definition->info[property] {
                    let ok =  true;
                    break;
                }
                if ctype_lower(property) {
                    break;
                }
                let property =  strtolower(property);
                if isset definition->info[property] {
                    let ok =  true;
                    break;
                }
            } while (0);
            if !(ok) {
                continue;
            }
            // inefficient call, since the validator will do this again
            if strtolower(trim(value)) !== "inherit" {
                // inherit works for everything (but only on the base property)
                let result =  definition->info[property]->validate(value, config, context);
            } else {
                let result = "inherit";
            }
            if result === false {
                continue;
            }
            if allow_duplicates {
                let new_declarations .= "{property}:{result};";
            } else {
                let propvalues[property] = result;
            }
        }
        context->destroy("CurrentCSSProperty");
        // procedure does not write the new CSS simultaneously, so it's
        // slightly inefficient, but it's the only way of getting rid of
        // duplicates. Perhaps config to optimize it, but not now.
        for prop, value in propvalues {
            let new_declarations .= "{prop}:{value};";
        }
        return  new_declarations ? new_declarations  : false;
    }

}