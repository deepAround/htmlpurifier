namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
/**
 * Module defines proprietary tags and attributes in HTML.
 * @warning If this module is enabled, standards-compliance is off!
 */
class HTMLModuleProprietary extends HTMLModule
{
    /**
     * @type string
     */
    public name = "Proprietary";
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var tmpArray27736d6e5a12e6582ee084ebc45a4fe6;
    
        let tmpArray27736d6e5a12e6582ee084ebc45a4fe6 = ["direction" : "Enum#left,right,up,down", "behavior" : "Enum#alternate", "width" : "Length", "height" : "Length", "scrolldelay" : "Number", "scrollamount" : "Number", "loop" : "Number", "bgcolor" : "Color", "hspace" : "Pixels", "vspace" : "Pixels"];
        this->addElement("marquee", "Inline", "Flow", "Common", tmpArray27736d6e5a12e6582ee084ebc45a4fe6);
    }

}