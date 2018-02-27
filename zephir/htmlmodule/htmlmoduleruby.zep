namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
/**
 * XHTML 1.1 Ruby Annotation Module, defines elements that indicate
 * short runs of text alongside base text for annotation or pronounciation.
 */
class HTMLModuleRuby extends HTMLModule
{
    /**
     * @type string
     */
    public name = "Ruby";
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var rb, rt, tmpArray8d746008bc11373fa589e796b8ae1333;
    
        this->addElement("ruby", "Inline", "Custom: ((rb, (rt | (rp, rt, rp))) | (rbc, rtc, rtc?))", "Common");
        this->addElement("rbc", false, "Required: rb", "Common");
        this->addElement("rtc", false, "Required: rt", "Common");
        let rb =  this->addElement("rb", false, "Inline", "Common");
        let rb->excludes =  ["ruby" : true];
        let tmpArray8d746008bc11373fa589e796b8ae1333 = ["rbspan" : "Number"];
        let rt =  this->addElement("rt", false, "Inline", "Common", tmpArray8d746008bc11373fa589e796b8ae1333);
        let rt->excludes =  ["ruby" : true];
        this->addElement("rp", false, "Optional: #PCDATA", "Common");
    }

}