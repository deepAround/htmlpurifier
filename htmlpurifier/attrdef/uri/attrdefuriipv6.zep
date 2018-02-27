namespace HTMLPurifier\AttrDef\Uri;

/**
 * Validates an IPv6 address.
 * @author Feyd @ forums.devnetwork.net (public domain)
 * @note This function requires brackets to have been removed from address
 *       in URI.
 */
class AttrDefURIIPv6 extends AttrDefURIIPv4
{
    /**
     * @param string $aIP
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string aIP, <Config> config, <Context> context)
    {
        var original, hex, blk, pre, ip, c, first, second, tmpListFirstSecond, piece;
    
        if !(this->ip4) {
            this->_loadRegex();
        }
        let original = aIP;
        let hex = "[0-9a-fA-F]";
        let blk =  "(?:" . hex . "{1,4})";
        let pre = "(?:/(?:12[0-8]|1[0-1][0-9]|[1-9][0-9]|[0-9]))";
        // /0 - /128
        //      prefix check
        if strpos(aIP, "/") !== false {
            if preg_match("#" . pre . "$#s", aIP, find) {
                let aIP =  substr(aIP, 0, 0 - strlen(find[0]));
                let find = null;
            
            } else {
                return false;
            }
        }
        //      IPv4-compatiblity check
        if preg_match("#(?<=:" . ")" . this->ip4 . "$#s", aIP, find) {
            let aIP =  substr(aIP, 0, 0 - strlen(find[0]));
            let ip =  explode(".", find[0]);
            let ip =  array_map("dechex", ip);
            let aIP .= ip[0] . ip[1] . ":" . ip[2] . ip[3];
            let find = null;
            let ip = null;
        
        }
        //      compression check
        let aIP =  explode("::", aIP);
        let c =  count(aIP);
        if c > 2 {
            return false;
        } elseif c == 2 {
            let tmpListFirstSecond = aIP;
            let first = tmpListFirstSecond[0];
            let second = tmpListFirstSecond[1];
            let first =  explode(":", first);
            let second =  explode(":", second);
            if count(first) + count(second) > 8 {
                return false;
            }
            while (count(first) < 8) {
                array_push(first, "0");
            }
            array_splice(first, 8 - count(second), 8, second);
            let aIP = first;
            let first = null;
            let second = null;
        
        } else {
            let aIP =  explode(":", aIP[0]);
        }
        let c =  count(aIP);
        if c != 8 {
            return false;
        }
        //      All the pieces should be 16-bit hex strings. Are they?
        for piece in aIP {
            if !(preg_match("#^[0-9a-fA-F]{4}$#s", sprintf("%04s", piece))) {
                return false;
            }
        }
        return original;
    }

}