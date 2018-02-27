namespace HTMLPurifier\AttrDef\Css;

/**
 * Validates based on {ident} CSS grammar production
 */
class AttrDefCSSIdent extends \HTMLPurifier\AttrDef
{
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        var pattern;
    
        let stringg =  trim(stringg);
        // early abort: '' and '0' (strings that convert to false) are invalid
        if !(stringg) {
            return false;
        }
        let pattern = "/^(-?[A-Za-z_][A-Za-z_\\-0-9]*)$/";
        if !(preg_match(pattern, stringg)) {
            return false;
        }
        return stringg;
    }

}