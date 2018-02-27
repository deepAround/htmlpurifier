namespace HTMLPurifier\URIScheme;

use HTMLPurifier\URIScheme;
/**
 * Validates ftp (File Transfer Protocol) URIs as defined by generic RFC 1738.
 */
class URISchemeFtp extends URIScheme
{
    /**
     * @type int
     */
    public default_port = 21;
    /**
     * @type bool
     */
    public browsable = true;
    // usually
    /**
     * @type bool
     */
    public hierarchical = true;
    /**
     * @param URI $uri
     * @param Config $config
     * @param Context $context
     * @return bool
     */
    public function doValidate(uri, <Config> config, <Context> context) -> bool
    {
        var semicolon_pos, type, type_ret, key, typecode, tmpListKeyTypecode;
    
        let uri->query =  null;
        // typecode check
        let semicolon_pos =  strrpos(uri->path, ";");
        // reverse
        if semicolon_pos !== false {
            let type =  substr(uri->path, semicolon_pos + 1);
            // no semicolon
            let uri->path =  substr(uri->path, 0, semicolon_pos);
            let type_ret = "";
            if strpos(type, "=") !== false {
                // figure out whether or not the declaration is correct
                let tmpListKeyTypecode = explode("=", type, 2);
                let key = tmpListKeyTypecode[0];
                let typecode = tmpListKeyTypecode[1];
                if key !== "type" {
                    // invalid key, tack it back on encoded
                    let uri->path .= "%3B" . type;
                } elseif typecode === "a" || typecode === "i" || typecode === "d" {
                    let type_ret = ";type={typecode}";
                }
            } else {
                let uri->path .= "%3B" . type;
            }
            let uri->path =  str_replace(";", "%3B", uri->path);
            let uri->path .= type_ret;
        }
        return true;
    }

}