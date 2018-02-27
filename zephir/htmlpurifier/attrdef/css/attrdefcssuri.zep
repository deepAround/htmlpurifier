namespace HTMLPurifier\AttrDef\Css;

/**
 * Validates a URI in CSS syntax, which uses url('http://example.com')
 * @note While theoretically speaking a URI in a CSS document could
 *       be non-embedded, as of CSS2 there is no such usage so we're
 *       generalizing it. This may need to be changed in the future.
 * @warning Since AttrDef_CSS blindly uses semicolons as
 *          the separator, you cannot put a literal semicolon in
 *          in the URI. Try percent encoding it, in that case.
 */
class AttrDefCSSURI extends \HTMLPurifier\AttrDef\AttrDefURI
{
    public function __construct() -> void
    {
        parent::__construct(true);
    }
    
    /**
     * @param string $uri_string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string uri_string, <Config> config, <Context> context)
    {
        var new_length, uri, quote, result, tmpArray20ab659e3c25625f9b55eb5caf476ac4, tmpArray1675643d64bc3a231aad16eb77f0cc06, tmpArrayee340b110100889a0bebe461d2228e07;
    
        // parse the URI out of the string and then pass it onto
        // the parent object
        let uri_string =  this->parseCDATA(uri_string);
        if strpos(uri_string, "url(") !== 0 {
            return false;
        }
        let uri_string =  substr(uri_string, 4);
        if strlen(uri_string) == 0 {
            return false;
        }
        let new_length =  strlen(uri_string) - 1;
        if uri_string[new_length] != ")" {
            return false;
        }
        let uri =  trim(substr(uri_string, 0, new_length));
        if !(empty(uri)) && (uri[0] == "'" || uri[0] == "\"") {
            let quote = uri[0];
            let new_length =  strlen(uri) - 1;
            if uri[new_length] !== quote {
                return false;
            }
            let uri =  substr(uri, 1, new_length - 1);
        }
        let uri =  this->expandCSSEscape(uri);
        let result =  parent::validate(uri, config, context);
        if result === false {
            return false;
        }
        // extra sanity check; should have been done by URI
        let tmpArray20ab659e3c25625f9b55eb5caf476ac4 = ["\"", "\\", "
", "", ""];
        let result =  str_replace(tmpArray20ab659e3c25625f9b55eb5caf476ac4, "", result);
        // suspicious characters are ()'; we're going to percent encode
        // them for safety.
        let tmpArray1675643d64bc3a231aad16eb77f0cc06 = ["(", ")", "'"];
        let tmpArrayee340b110100889a0bebe461d2228e07 = ["%28", "%29", "%27"];
        let result =  str_replace(tmpArray1675643d64bc3a231aad16eb77f0cc06, tmpArrayee340b110100889a0bebe461d2228e07, result);
        // there's an extra bug where ampersands lose their escaping on
        // an innerHTML cycle, so a very unlucky query parameter could
        // then change the meaning of the URL.  Unfortunately, there's
        // not much we can do about that...
        return "url(\"{result}\")";
    }

}