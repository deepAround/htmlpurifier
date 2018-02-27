namespace HTMLPurifier\AttrDef\Html;

/**
 * Validates contents based on NMTOKENS attribute type.
 */
class AttrDefHTMLNmtokens extends \HTMLPurifier\AttrDef
{
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        var tokens;
    
        let stringg =  trim(stringg);
        // early abort: '' and '0' (strings that convert to false) are invalid
        if !(stringg) {
            return false;
        }
        let tokens =  this->split(stringg, config, context);
        let tokens =  this->filter(tokens, config, context);
        if empty(tokens) {
            return false;
        }
        return implode(" ", tokens);
    }
    
    /**
     * Splits a space separated list of tokens into its constituent parts.
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return array
     */
    protected function split(string stringg, <Config> config, <Context> context) -> array
    {
        var pattern;
    
        // OPTIMIZABLE!
        // do the preg_match, capture all subpatterns for reformulation
        // we don't support U+00A1 and up codepoints or
        // escaping because I don't know how to do that with regexps
        // and plus it would complicate optimization efforts (you never
        // see that anyway).
        let pattern =  "/(?:(?<=\\s)|\\A)" . "((?:--|-?[A-Za-z_])[A-Za-z_\\-0-9]*)" . "(?:(?=\\s)|\\z)/";
        // look ahead for space or string end
        preg_match_all(pattern, stringg, matches);
        return matches[1];
    }
    
    /**
     * Template method for removing certain tokens based on arbitrary criteria.
     * @note If we wanted to be really functional, we'd do an array_filter
     *       with a callback. But... we're not.
     * @param array $tokens
     * @param Config $config
     * @param Context $context
     * @return array
     */
    protected function filter(array tokens, <Config> config, <Context> context) -> array
    {
        return tokens;
    }

}