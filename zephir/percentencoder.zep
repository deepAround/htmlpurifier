namespace HTMLPurifier;

/**
 * Class that handles operations involving percent-encoding in URIs.
 *
 * @warning
 *      Be careful when reusing instances of PercentEncoder. The object
 *      you use for normalize() SHOULD NOT be used for encode(), or
 *      vice-versa.
 */
class PercentEncoder
{
    /**
     * Reserved characters to preserve when using encode().
     * @type array
     */
    protected preserve = [];
    /**
     * String of characters that should be preserved while using encode().
     * @param bool $preserve
     */
    public function __construct(bool preserve = false) -> void
    {
        var i, c;
    
        // unreserved letters, ought to const-ify
        let i = 48;
        for i in range(48, 57) {
            // digits
            let this->preserve[i] = true;
        }
        let i = 65;
        for i in range(65, 90) {
            // upper-case
            let this->preserve[i] = true;
        }
        let i = 97;
        for i in range(97, 122) {
            // lower-case
            let this->preserve[i] = true;
        }
        let this->preserve[45] = true;
        // Dash         -
        let this->preserve[46] = true;
        // Period       .
        let this->preserve[95] = true;
        // Underscore   _
        let this->preserve[126] = true;
        // Tilde        ~
        // extra letters not to escape
        if preserve !== false {
            let i = 0;
            let c =  strlen(preserve);
            for i in range(0, c) {
                let this->preserve[ord(preserve[i])] = true;
            }
        }
    }
    
    /**
     * Our replacement for urlencode, it encodes all non-reserved characters,
     * as well as any extra characters that were instructed to be preserved.
     * @note
     *      Assumes that the string has already been normalized, making any
     *      and all percent escape sequences valid. Percents will not be
     *      re-escaped, regardless of their status in $preserve
     * @param string $string String to be encoded
     * @return string Encoded string.
     */
    public function encode(string stringg) -> string
    {
        var ret, i, c, intt;
    
        let ret = "";
        let i = 0;
        let c =  strlen(stringg);
        for i in range(0, c) {
            let intt =  ord(stringg[i]);
            if stringg[i] !== "%" && !(isset this->preserve[intt]) {
                let ret .= "%" . sprintf("%02X", intt);
            } else {
                let ret .= stringg[i];
            }
        }
        return ret;
    }
    
    /**
     * Fix up percent-encoding by decoding unreserved characters and normalizing.
     * @warning This function is affected by $preserve, even though the
     *          usual desired behavior is for this not to preserve those
     *          characters. Be careful when reusing instances of PercentEncoder!
     * @param string $string String to normalize
     * @return string
     */
    public function normalize(string stringg) -> string
    {
        var parts, ret, part, length, encoding, text, intt;
    
        if stringg == "" {
            return "";
        }
        let parts =  explode("%", stringg);
        let ret =  array_shift(parts);
        for part in parts {
            let length =  strlen(part);
            if length < 2 {
                let ret .= "%25" . part;
                continue;
            }
            let encoding =  substr(part, 0, 2);
            let text =  substr(part, 2);
            if !(ctype_xdigit(encoding)) {
                let ret .= "%25" . part;
                continue;
            }
            let intt =  hexdec(encoding);
            if isset this->preserve[intt] {
                let ret .= chr(intt) . text;
                continue;
            }
            let encoding =  strtoupper(encoding);
            let ret .= "%" . encoding . text;
        }
        return ret;
    }

}