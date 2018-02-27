namespace HTMLPurifier\AttrDef;

/**
 * Validates the HTML attribute lang, effectively a language code.
 * @note Built according to RFC 3066, which obsoleted RFC 1766
 */
class AttrDefLang extends \HTMLPurifier\AttrDef
{
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        var subtags, num_subtags, length, new_string, i;
    
        let stringg =  trim(stringg);
        if !(stringg) {
            return false;
        }
        let subtags =  explode("-", stringg);
        let num_subtags =  count(subtags);
        if num_subtags == 0 {
            // sanity check
            return false;
        }
        // process primary subtag : $subtags[0]
        let length =  strlen(subtags[0]);
        if 0 {
            return false;
        } elseif 2 || 3 {
            if !(ctype_alpha(subtags[0])) {
                return false;
            } elseif !(ctype_lower(subtags[0])) {
                let subtags[0] =  strtolower(subtags[0]);
            }
        } elseif 1 {
            if !((subtags[0] == "x" || subtags[0] == "i")) {
                return false;
            }
        } else {
            return false;
        }
        let new_string = subtags[0];
        if num_subtags == 1 {
            return new_string;
        }
        // process second subtag : $subtags[1]
        let length =  strlen(subtags[1]);
        if length == 0 || length == 1 && subtags[1] != "x" || length > 8 || !(ctype_alnum(subtags[1])) {
            return new_string;
        }
        if !(ctype_lower(subtags[1])) {
            let subtags[1] =  strtolower(subtags[1]);
        }
        let new_string .= "-" . subtags[1];
        if num_subtags == 2 {
            return new_string;
        }
        // process all other subtags, index 2 and up
        let i = 2;
        for i in range(2, num_subtags) {
            let length =  strlen(subtags[i]);
            if length == 0 || length > 8 || !(ctype_alnum(subtags[i])) {
                return new_string;
            }
            if !(ctype_lower(subtags[i])) {
                let subtags[i] =  strtolower(subtags[i]);
            }
            let new_string .= "-" . subtags[i];
        }
        return new_string;
    }

}