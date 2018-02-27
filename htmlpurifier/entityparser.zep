namespace HTMLPurifier;

// if want to implement error collecting here, we'll need to use some sort
// of global data (probably trigger_error) because it's impossible to pass
// $config or $context to the callback functions.
/**
 * Handles referencing and derefencing character entities
 */
class EntityParser
{
    /**
     * Reference to entity lookup table.
     * @type EntityLookup
     */
    protected _entity_lookup;
    /**
     * Callback regex string for entities in text.
     * @type string
     */
    protected _textEntitiesRegex;
    /**
     * Callback regex string for entities in attributes.
     * @type string
     */
    protected _attrEntitiesRegex;
    /**
     * Tests if the beginning of a string is a semi-optional regex
     */
    protected _semiOptionalPrefixRegex;
    public function __construct() -> void
    {
        var semi_optional;
    
        // From
        // http://stackoverflow.com/questions/15532252/why-is-reg-being-rendered-as-without-the-bounding-semicolon
        let semi_optional = "quot|QUOT|lt|LT|gt|GT|amp|AMP|AElig|Aacute|Acirc|Agrave|Aring|Atilde|Auml|COPY|Ccedil|ETH|Eacute|Ecirc|Egrave|Euml|Iacute|Icirc|Igrave|Iuml|Ntilde|Oacute|Ocirc|Ograve|Oslash|Otilde|Ouml|REG|THORN|Uacute|Ucirc|Ugrave|Uuml|Yacute|aacute|acirc|acute|aelig|agrave|aring|atilde|auml|brvbar|ccedil|cedil|cent|copy|curren|deg|divide|eacute|ecirc|egrave|eth|euml|frac12|frac14|frac34|iacute|icirc|iexcl|igrave|iquest|iuml|laquo|macr|micro|middot|nbsp|not|ntilde|oacute|ocirc|ograve|ordf|ordm|oslash|otilde|ouml|para|plusmn|pound|raquo|reg|sect|shy|sup1|sup2|sup3|szlig|thorn|times|uacute|ucirc|ugrave|uml|uuml|yacute|yen|yuml";
        // NB: three empty captures to put the fourth match in the right
        // place
        let this->_semiOptionalPrefixRegex = "/&()()()({semi_optional})/";
        let this->_textEntitiesRegex =  "/&(?:" . "[#]x([a-fA-F0-9]+);?|" . "[#]0*(\\d+);?|" . "([A-Za-z_:][A-Za-z0-9.\\-_:]*);|" . "({semi_optional})" . ")/";
        let this->_attrEntitiesRegex =  "/&(?:" . "[#]x([a-fA-F0-9]+);?|" . "[#]0*(\\d+);?|" . "([A-Za-z_:][A-Za-z0-9.\\-_:]*);|" . "({semi_optional})(?![=;A-Za-z0-9])" . ")/";
    }
    
    /**
     * Substitute entities with the parsed equivalents.  Use this on
     * textual data in an HTML document (as opposed to attributes.)
     *
     * @param string $string String to have entities parsed.
     * @return string Parsed string.
     */
    public function substituteTextEntities(string stringg) -> string
    {
        var tmpArrayb510bacf5b6048a8cc0b52f88d606dc3;
    
        let tmpArrayb510bacf5b6048a8cc0b52f88d606dc3 = [this, "entityCallback"];
        return preg_replace_callback(this->_textEntitiesRegex, tmpArrayb510bacf5b6048a8cc0b52f88d606dc3, stringg);
    }
    
    /**
     * Substitute entities with the parsed equivalents.  Use this on
     * attribute contents in documents.
     *
     * @param string $string String to have entities parsed.
     * @return string Parsed string.
     */
    public function substituteAttrEntities(string stringg) -> string
    {
        var tmpArray7e0b74d49b07afafe5c7a1b674a7cd68;
    
        let tmpArray7e0b74d49b07afafe5c7a1b674a7cd68 = [this, "entityCallback"];
        return preg_replace_callback(this->_attrEntitiesRegex, tmpArray7e0b74d49b07afafe5c7a1b674a7cd68, stringg);
    }
    
    /**
     * Callback function for substituteNonSpecialEntities() that does the work.
     *
     * @param array $matches  PCRE matches array, with 0 the entire match, and
     *                  either index 1, 2 or 3 set with a hex value, dec value,
     *                  or string (respectively).
     * @return string Replacement string.
     */
    protected function entityCallback(array matches) -> string
    {
        var entity, hex_part, dec_part, named_part, tmpArray85ffc965d607e446beb9aeced9fb6b1e;
    
        let entity = matches[0];
        let hex_part =  matches[1];
        let dec_part =  matches[2];
        let named_part =  empty(matches[3]) ? matches[4]  : matches[3];
        if hex_part !== NULL && hex_part !== "" {
            return Encoder::unichr(hexdec(hex_part));
        } elseif dec_part !== NULL && dec_part !== "" {
            return Encoder::unichr((int) dec_part);
        } else {
            if !(this->_entity_lookup) {
                let this->_entity_lookup =  EntityLookup::instance();
            }
            if isset this->_entity_lookup->table[named_part] {
                return this->_entity_lookup->table[named_part];
            } else {
                // exact match didn't match anything, so test if
                // any of the semicolon optional match the prefix.
                // Test that this is an EXACT match is important to
                // prevent infinite loop
                if !(empty(matches[3])) {
                    let tmpArray85ffc965d607e446beb9aeced9fb6b1e = [this, "entityCallback"];
                    return preg_replace_callback(this->_semiOptionalPrefixRegex, tmpArray85ffc965d607e446beb9aeced9fb6b1e, entity);
                }
                return entity;
            }
        }
    }
    
    // LEGACY CODE BELOW
    /**
     * Callback regex string for parsing entities.
     * @type string
     */
    protected _substituteEntitiesRegex = "/&(?:[#]x([a-fA-F0-9]+)|[#]0*(\\d+)|([A-Za-z_:][A-Za-z0-9.\\-_:]*));?/";
    //     1. hex             2. dec      3. string (XML style)
    /**
     * Decimal to parsed string conversion table for special entities.
     * @type array
     */
    protected _special_dec2str = [34 : "\"", 38 : "&", 39 : "'", 60 : "<", 62 : ">"];
    /**
     * Stripped entity names to decimal conversion table for special entities.
     * @type array
     */
    protected _special_ent2dec = ["quot" : 34, "amp" : 38, "lt" : 60, "gt" : 62];
    /**
     * Substitutes non-special entities with their parsed equivalents. Since
     * running this whenever you have parsed character is t3h 5uck, we run
     * it before everything else.
     *
     * @param string $string String to have non-special entities parsed.
     * @return string Parsed string.
     */
    public function substituteNonSpecialEntities(string stringg) -> string
    {
        var tmpArray44bb42bc3afff7f91e5b0e7f7c28a885;
    
        // it will try to detect missing semicolons, but don't rely on it
        let tmpArray44bb42bc3afff7f91e5b0e7f7c28a885 = [this, "nonSpecialEntityCallback"];
        return preg_replace_callback(this->_substituteEntitiesRegex, tmpArray44bb42bc3afff7f91e5b0e7f7c28a885, stringg);
    }
    
    /**
     * Callback function for substituteNonSpecialEntities() that does the work.
     *
     * @param array $matches  PCRE matches array, with 0 the entire match, and
     *                  either index 1, 2 or 3 set with a hex value, dec value,
     *                  or string (respectively).
     * @return string Replacement string.
     */
    protected function nonSpecialEntityCallback(array matches) -> string
    {
        var entity, is_num, is_hex, code;
    
        // replaces all but big five
        let entity = matches[0];
        let is_num =  matches[0][1] === "#";
        if is_num {
            let is_hex =  entity[2] === "x";
            let code =  is_hex ? hexdec(matches[1])  : (int) matches[2];
            // abort for special characters
            if isset this->_special_dec2str[code] {
                return entity;
            }
            return Encoder::unichr(code);
        } else {
            if isset this->_special_ent2dec[matches[3]] {
                return entity;
            }
            if !(this->_entity_lookup) {
                let this->_entity_lookup =  EntityLookup::instance();
            }
            if isset this->_entity_lookup->table[matches[3]] {
                return this->_entity_lookup->table[matches[3]];
            } else {
                return entity;
            }
        }
    }
    
    /**
     * Substitutes only special entities with their parsed equivalents.
     *
     * @notice We try to avoid calling this function because otherwise, it
     * would have to be called a lot (for every parsed section).
     *
     * @param string $string String to have non-special entities parsed.
     * @return string Parsed string.
     */
    public function substituteSpecialEntities(string stringg) -> string
    {
        var tmpArray1ef3114af2ef8d4dc31c4e3a02a12c97;
    
        let tmpArray1ef3114af2ef8d4dc31c4e3a02a12c97 = [this, "specialEntityCallback"];
        return preg_replace_callback(this->_substituteEntitiesRegex, tmpArray1ef3114af2ef8d4dc31c4e3a02a12c97, stringg);
    }
    
    /**
     * Callback function for substituteSpecialEntities() that does the work.
     *
     * This callback has same syntax as nonSpecialEntityCallback().
     *
     * @param array $matches  PCRE-style matches array, with 0 the entire match, and
     *                  either index 1, 2 or 3 set with a hex value, dec value,
     *                  or string (respectively).
     * @return string Replacement string.
     */
    protected function specialEntityCallback(array matches) -> string
    {
        var entity, is_num, is_hex, intt;
    
        let entity = matches[0];
        let is_num =  matches[0][1] === "#";
        if is_num {
            let is_hex =  entity[2] === "x";
            let intt =  is_hex ? hexdec(matches[1])  : (int) matches[2];
            return  isset this->_special_dec2str[intt] ? this->_special_dec2str[intt]  : entity;
        } else {
            return  isset this->_special_ent2dec[matches[3]] ? this->_special_dec2str[this->_special_ent2dec[matches[3]]]  : entity;
        }
    }

}