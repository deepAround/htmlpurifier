namespace HTMLPurifier\AttrDef\Html;

/**
 * Implements special behavior for class attribute (normally NMTOKENS)
 */
class AttrDefHTMLClass extends AttrDefHTMLNmtokens
{
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    protected function split(string stringg, <Config> config, <Context> context)
    {
        var name;
    
        // really, this twiddle should be lazy loaded
        let name =  config->getDefinition("HTML")->doctype->name;
        if name == "XHTML 1.1" || name == "XHTML 2.0" {
            return parent::split(stringg, config, context);
        } else {
            return preg_split("/\\s+/", stringg);
        }
    }
    
    /**
     * @param array $tokens
     * @param Config $config
     * @param Context $context
     * @return array
     */
    protected function filter(array tokens, <Config> config, <Context> context) -> array
    {
        var allowed, forbidden, ret, token;
    
        let allowed =  config->get("Attr.AllowedClasses");
        let forbidden =  config->get("Attr.ForbiddenClasses");
        let ret =  [];
        for token in tokens {
            if (allowed === null || isset allowed[token]) && !(isset forbidden[token]) && !(in_array(token, ret, true)) {
                let ret[] = token;
            }
        }
        return ret;
    }

}