namespace HTMLPurifier\AttrDef\Css;

/* W3C says:
   [ // adjective and number must be in correct order, even if
   // you could switch them without introducing ambiguity.
   // some browsers support that syntax
   [
   <percentage> | <length> | left | center | right
   ]
   [
   <percentage> | <length> | top | center | bottom
   ]?
   ] |
   [ // this signifies that the vertical and horizontal adjectives
   // can be arbitrarily ordered, however, there can only be two,
   // one of each, or none at all
   [
   left | center | right
   ] ||
   [
   top | center | bottom
   ]
   ]
   top, left = 0%
   center, (none) = 50%
   bottom, right = 100%
*/
/* QuirksMode says:
   keyword + length/percentage must be ordered correctly, as per W3C
   Internet Explorer and Opera, however, support arbitrary ordering. We
   should fix it up.
   Minor issue though, not strictly necessary.
*/
// control freaks may appreciate the ability to convert these to
// percentages or something, but it's not necessary
/**
 * Validates the value of background-position.
 */
class AttrDefCSSBackgroundPosition extends \HTMLPurifier\AttrDef
{
    /**
     * @type AttrDefCSSLength
     */
    protected length;
    /**
     * @type AttrDefCSSPercentage
     */
    protected percentage;
    public function __construct() -> void
    {
        let this->length =  new AttrDefCSSLength();
        let this->percentage =  new AttrDefCSSPercentage();
    }
    
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        var bits, keywords, measures, i, lookup, bit, lbit, status, r, ret;
    
        let stringg =  this->parseCDATA(stringg);
        let bits =  explode(" ", stringg);
        let keywords =  [];
        let keywords["h"] = false;
        // left, right
        let keywords["v"] = false;
        // top, bottom
        let keywords["ch"] = false;
        // center (first word)
        let keywords["cv"] = false;
        // center (second word)
        let measures =  [];
        let i = 0;
        let lookup =  ["top" : "v", "bottom" : "v", "left" : "h", "right" : "h", "center" : "c"];
        for bit in bits {
            if bit === "" {
                continue;
            }
            // test for keyword
            let lbit =  ctype_lower(bit) ? bit  : strtolower(bit);
            if isset lookup[lbit] {
                let status = lookup[lbit];
                if status == "c" {
                    if i == 0 {
                        let status = "ch";
                    } else {
                        let status = "cv";
                    }
                }
                let keywords[status] = lbit;
                let i++;
            }
            // test for length
            let r =  this->length->validate(bit, config, context);
            if r !== false {
                let measures[] = r;
                let i++;
            }
            // test for percentage
            let r =  this->percentage->validate(bit, config, context);
            if r !== false {
                let measures[] = r;
                let i++;
            }
        }
        if !(i) {
            return false;
        }
        // no valid values were caught
        let ret =  [];
        // first keyword
        if keywords["h"] {
            let ret[] = keywords["h"];
        } elseif keywords["ch"] {
            let ret[] = keywords["ch"];
            let keywords["cv"] = false;
        } elseif count(measures) {
            let ret[] =  array_shift(measures);
        }
        if keywords["v"] {
            let ret[] = keywords["v"];
        } elseif keywords["cv"] {
            let ret[] = keywords["cv"];
        } elseif count(measures) {
            let ret[] =  array_shift(measures);
        }
        if empty(ret) {
            return false;
        }
        return implode(" ", ret);
    }

}