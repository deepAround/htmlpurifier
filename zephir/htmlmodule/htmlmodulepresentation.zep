namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
/**
 * XHTML 1.1 Presentation Module, defines simple presentation-related
 * markup. Text Extension Module.
 * @note The official XML Schema and DTD specs further divide this into
 *       two modules:
 *          - Block Presentation (hr)
 *          - Inline Presentation (b, big, i, small, sub, sup, tt)
 *       We have chosen not to heed this distinction, as content_sets
 *       provides satisfactory disambiguation.
 */
class HTMLModulePresentation extends HTMLModule
{
    /**
     * @type string
     */
    public name = "Presentation";
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var b, big, i, small, tt;
    
        this->addElement("hr", "Block", "Empty", "Common");
        this->addElement("sub", "Inline", "Inline", "Common");
        this->addElement("sup", "Inline", "Inline", "Common");
        let b =  this->addElement("b", "Inline", "Inline", "Common");
        let b->formatting =  true;
        let big =  this->addElement("big", "Inline", "Inline", "Common");
        let big->formatting =  true;
        let i =  this->addElement("i", "Inline", "Inline", "Common");
        let i->formatting =  true;
        let small =  this->addElement("small", "Inline", "Inline", "Common");
        let small->formatting =  true;
        let tt =  this->addElement("tt", "Inline", "Inline", "Common");
        let tt->formatting =  true;
    }

}