namespace HTMLPurifier\AttrDef\Uri;

use HTMLPurifier\Exception;
/**
 * Validates a host according to the IPv4, IPv6 and DNS (future) specifications.
 */
class AttrDefURIHost extends \HTMLPurifier\AttrDef
{
    /**
     * IPv4 sub-validator.
     * @type AttrDefURIIPv4
     */
    protected ipv4;
    /**
     * IPv6 sub-validator.
     * @type AttrDefURIIPv6
     */
    protected ipv6;
    public function __construct() -> void
    {
        let this->ipv4 =  new AttrDefURIIPv4();
        let this->ipv6 =  new AttrDefURIIPv6();
    }
    
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        var length, ip, valid, ipv4, underscore, a, an, and, domainlabel, toplabel, idna, tmpArrayefae595285390130cc388edfca589c10, parts, new_parts, part, encodable, i, c, e;
    
        let length =  strlen(stringg);
        // empty hostname is OK; it's usually semantically equivalent:
        // the default host as defined by a URI scheme is used:
        //
        //      If the URI scheme defines a default for host, then that
        //      default applies when the host subcomponent is undefined
        //      or when the registered name is empty (zero length).
        if stringg === "" {
            return "";
        }
        if length > 1 && stringg[0] === "[" && stringg[length - 1] === "]" {
            //IPv6
            let ip =  substr(stringg, 1, length - 2);
            let valid =  this->ipv6->validate(ip, config, context);
            if valid === false {
                return false;
            }
            return "[" . valid . "]";
        }
        // need to do checks on unusual encodings too
        let ipv4 =  this->ipv4->validate(stringg, config, context);
        if ipv4 !== false {
            return ipv4;
        }
        // A regular domain name.
        // This doesn't match I18N domain names, but we don't have proper IRI support,
        // so force users to insert Punycode.
        // There is not a good sense in which underscores should be
        // allowed, since it's technically not! (And if you go as
        // far to allow everything as specified by the DNS spec...
        // well, that's literally everything, modulo some space limits
        // for the components and the overall name (which, by the way,
        // we are NOT checking!).  So we (arbitrarily) decide this:
        // let's allow underscores wherever we would have allowed
        // hyphens, if they are enabled.  This is a pretty good match
        // for browser behavior, for example, a large number of browsers
        // cannot handle foo_.example.com, but foo_bar.example.com is
        // fairly well supported.
        let underscore =  config->get("Core.AllowHostnameUnderscore") ? "_"  : "";
        // Based off of RFC 1738, but amended so that
        // as per RFC 3696, the top label need only not be all numeric.
        // The productions describing this are:
        let a = "[a-z]";
        // alpha
        let an = "[a-z0-9]";
        // alphanum
        let and = "[a-z0-9-{underscore}]";
        // alphanum | "-"
        // domainlabel = alphanum | alphanum *( alphanum | "-" ) alphanum
        let domainlabel = "{an}(?:{and}*{an})?";
        // AMENDED as per RFC 3696
        // toplabel    = alphanum | alphanum *( alphanum | "-" ) alphanum
        //      side condition: not all numeric
        let toplabel = "{an}(?:{and}*{an})?";
        // hostname    = *( domainlabel "." ) toplabel [ "." ]
        if preg_match("/^(?:{domainlabel}\\.)*({toplabel})\\.?\$/i", stringg, matches) {
            if !(ctype_digit(matches[1])) {
                return stringg;
            }
        }
        // PHP 5.3 and later support this functionality natively
        if function_exists("idn_to_ascii") {
            let stringg =  idn_to_ascii(stringg, IDNA_NONTRANSITIONAL_TO_ASCII, INTL_IDNA_VARIANT_UTS46);
        } elseif config->get("Core.EnableIDNA") {
            let idna =  new Net_IDNA2(["encoding" : "utf8", "overlong" : false, "strict" : true]);
            // we need to encode each period separately
            let parts =  explode(".", stringg);
            try {
                let new_parts =  [];
                for part in parts {
                    let encodable =  false;
                    let i = 0;
                    let c =  strlen(part);
                    for i in range(0, c) {
                        if ord(part[i]) > 122 {
                            let encodable =  true;
                            break;
                        }
                    }
                    if !(encodable) {
                        let new_parts[] = part;
                    } else {
                        let new_parts[] =  idna->encode(part);
                    }
                }
                let stringg =  implode(".", new_parts);
            } catch Exception, e {
            }
        }
        // Try again
        if preg_match("/^({domainlabel}\\.)*{toplabel}\\.?\$/i", stringg) {
            return stringg;
        }
        return false;
    }

}