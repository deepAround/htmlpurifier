namespace HTMLPurifier;

/**
 * Parses a URI into the components and fragment identifier as specified
 * by RFC 3986.
 */
class URIParser
{
    /**
     * Instance of PercentEncoder to do normalization with.
     */
    protected percentEncoder;
    public function __construct() -> void
    {
        let this->percentEncoder =  new PercentEncoder();
    }
    
    /**
     * Parses a URI.
     * @param $uri string URI to parse
     * @return URI representation of URI. This representation has
     *         not been validated yet and may not conform to RFC.
     */
    public function parse(uri)
    {
        var r_URI, matches, result, scheme, authority, path, query, fragment, r_authority, userinfo, host, port;
    
        let uri =  this->percentEncoder->normalize(uri);
        // Regexp is as per Appendix B.
        // Note that ["<>] are an addition to the RFC's recommended
        // characters, because they represent external delimeters.
        let r_URI =  "!" . "(([a-zA-Z0-9\\.\\+\\-]+):)?" . "(//([^/?#\"<>]*))?" . "([^?#\"<>]*)" . "(\\?([^#\"<>]*))?" . "(#([^\"<>]*))?" . "!";
        let matches =  [];
        let result =  preg_match(r_URI, uri, matches);
        if !(result) {
            return false;
        }
        // *really* invalid URI
        // seperate out parts
        let scheme =  !(empty(matches[1])) ? matches[2]  : null;
        let authority =  !(empty(matches[3])) ? matches[4]  : null;
        let path = matches[5];
        // always present, can be empty
        let query =  !(empty(matches[6])) ? matches[7]  : null;
        let fragment =  !(empty(matches[8])) ? matches[9]  : null;
        // further parse authority
        if authority !== null {
            let r_authority = "/^((.+?)@)?(\\[[^\\]]+\\]|[^:]*)(:(\\d*))?/";
            let matches =  [];
            preg_match(r_authority, authority, matches);
            let userinfo =  !(empty(matches[1])) ? matches[2]  : null;
            let host =  !(empty(matches[3])) ? matches[3]  : "";
            let port =  !(empty(matches[4])) ? (int) matches[5]  : null;
        } else {
            let port = null;
            let userinfo = null;
            let host = null;
            ;
        }
        return new uri(scheme, userinfo, host, port, path, query, fragment);
    }

}