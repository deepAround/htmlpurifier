namespace HTMLPurifier;

use HTMLPurifier\AttrDef\AttrDefClone;
use HTMLPurifier\AttrDef\AttrDefEnum;
use HTMLPurifier\AttrDef\AttrDefInteger;
use HTMLPurifier\AttrDef\AttrDefLang;
use HTMLPurifier\AttrDef\AttrDefText;
use HTMLPurifier\AttrDef\AttrDefURI;
use HTMLPurifier\AttrDef\Html\AttrDefHTMLBool;
use HTMLPurifier\AttrDef\Html\AttrDefHTMLClass;
use HTMLPurifier\AttrDef\Html\AttrDefHTMLColor;
use HTMLPurifier\AttrDef\Html\AttrDefHTMLFrameTarget;
use HTMLPurifier\AttrDef\Html\AttrDefHTMLID;
use HTMLPurifier\AttrDef\Html\AttrDefHTMLLength;
use HTMLPurifier\AttrDef\Html\AttrDefHTMLMultiLength;
use HTMLPurifier\AttrDef\Html\AttrDefHTMLNmtokens;
use HTMLPurifier\AttrDef\Html\AttrDefHTMLPixels;
/**
 * Provides lookup array of attribute types to AttrDef objects
 */
class AttrTypes
{
    /**
     * Lookup array of attribute string identifiers to concrete implementations.
     * @type AttrDef[]
     */
    protected info = [];
    /**
     * Constructs the info array, supplying default implementations for attribute
     * types.
     */
    public function __construct() -> void
    {
        // XXX This is kind of poor, since we don't actually /clone/
        // instances; instead, we use the supplied make() attribute. So,
        // the underlying class must know how to deal with arguments.
        // With the old implementation of Enum, that ignored its
        // arguments when handling a make dispatch, the IAlign
        // definition wouldn't work.
        // pseudo-types, must be instantiated via shorthand
        let this->info["Enum"] = new AttrDefEnum();
        let this->info["Bool"] = new AttrDefHTMLBool();
        let this->info["CDATA"] = new AttrDefText();
        let this->info["ID"] = new AttrDefHTMLID();
        let this->info["Length"] = new AttrDefHTMLLength();
        let this->info["MultiLength"] = new AttrDefHTMLMultiLength();
        let this->info["NMTOKENS"] = new AttrDefHTMLNmtokens();
        let this->info["Pixels"] = new AttrDefHTMLPixels();
        let this->info["Text"] = new AttrDefText();
        let this->info["URI"] = new AttrDefURI();
        let this->info["LanguageCode"] = new AttrDefLang();
        let this->info["Color"] = new AttrDefHTMLColor();
        let this->info["IAlign"] = self::makeEnum("top,middle,bottom,left,right");
        let this->info["LAlign"] = self::makeEnum("top,bottom,left,right");
        let this->info["FrameTarget"] = new AttrDefHTMLFrameTarget();
        // unimplemented aliases
        let this->info["ContentType"] = new AttrDefText();
        let this->info["ContentTypes"] = new AttrDefText();
        let this->info["Charsets"] = new AttrDefText();
        let this->info["Character"] = new AttrDefText();
        // "proprietary" types
        let this->info["Class"] = new AttrDefHTMLClass();
        // number is really a positive integer (one or more digits)
        // FIXME: ^^ not always, see start and value of list items
        let this->info["Number"] = new AttrDefInteger(false, false, true);
    }
    
    protected static function makeEnum(in)
    {
        return new AttrDefClone(new AttrDefEnum(explode(",", in)));
    }
    
    /**
     * Retrieves a type
     * @param string $type String type name
     * @return AttrDef Object AttrDef for type
     */
    public function get(string type) -> <AttrDef>
    {
        var stringg, tmpListTypeStringg;
    
        // determine if there is any extra info tacked on
        if strpos(type, "#") !== false {
            let tmpListTypeStringg = explode("#", type, 2);
            let type = tmpListTypeStringg[0];
            let stringg = tmpListTypeStringg[1];
        } else {
            let stringg = "";
        }
        if !(isset this->info[type]) {
            trigger_error("Cannot retrieve undefined attribute type " . type, E_USER_ERROR);
            return;
        }
        return this->info[type]->make(stringg);
    }
    
    /**
     * Sets a new implementation for a type
     * @param string $type String type name
     * @param AttrDef $impl Object AttrDef for type
     */
    public function set(string type, <AttrDef> impl) -> void
    {
        let this->info[type] = impl;
    }

}