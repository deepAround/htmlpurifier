namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
/**
 * XHTML 1.1 Text Module, defines basic text containers. Core Module.
 * @note In the normative XML Schema specification, this module
 *       is further abstracted into the following modules:
 *          - Block Phrasal (address, blockquote, pre, h1, h2, h3, h4, h5, h6)
 *          - Block Structural (div, p)
 *          - Inline Phrasal (abbr, acronym, cite, code, dfn, em, kbd, q, samp, strong, var)
 *          - Inline Structural (br, span)
 *       This module, functionally, does not distinguish between these
 *       sub-modules, but the code is internally structured to reflect
 *       these distinctions.
 */
class HTMLModuleText extends HTMLModule
{
    /**
     * @type string
     */
    public name = "Text";
    /**
     * @type array
     */
    public content_sets = ["Flow" : "Heading | Block | Inline"];
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var tmpArraya17dfe7b54aa67fffa87700dfdd572db, em, strong, code, tmpArraye27db746a9edb8f6483fa8c8f8ae7287, pre, p, tmpArrayc6a2060d1a207c8fdeae528e99c058b6;
    
        // Inline Phrasal -------------------------------------------------
        this->addElement("abbr", "Inline", "Inline", "Common");
        this->addElement("acronym", "Inline", "Inline", "Common");
        this->addElement("cite", "Inline", "Inline", "Common");
        this->addElement("dfn", "Inline", "Inline", "Common");
        this->addElement("kbd", "Inline", "Inline", "Common");
        let tmpArraya17dfe7b54aa67fffa87700dfdd572db = ["cite" : "URI"];
        this->addElement("q", "Inline", "Inline", "Common", tmpArraya17dfe7b54aa67fffa87700dfdd572db);
        this->addElement("samp", "Inline", "Inline", "Common");
        this->addElement("var", "Inline", "Inline", "Common");
        let em =  this->addElement("em", "Inline", "Inline", "Common");
        let em->formatting =  true;
        let strong =  this->addElement("strong", "Inline", "Inline", "Common");
        let strong->formatting =  true;
        let code =  this->addElement("code", "Inline", "Inline", "Common");
        let code->formatting =  true;
        // Inline Structural ----------------------------------------------
        this->addElement("span", "Inline", "Inline", "Common");
        this->addElement("br", "Inline", "Empty", "Core");
        // Block Phrasal --------------------------------------------------
        this->addElement("address", "Block", "Inline", "Common");
        let tmpArraye27db746a9edb8f6483fa8c8f8ae7287 = ["cite" : "URI"];
        this->addElement("blockquote", "Block", "Optional: Heading | Block | List", "Common", tmpArraye27db746a9edb8f6483fa8c8f8ae7287);
        let pre =  this->addElement("pre", "Block", "Inline", "Common");
        let pre->excludes =  this->makeLookup("img", "big", "small", "object", "applet", "font", "basefont");
        this->addElement("h1", "Heading", "Inline", "Common");
        this->addElement("h2", "Heading", "Inline", "Common");
        this->addElement("h3", "Heading", "Inline", "Common");
        this->addElement("h4", "Heading", "Inline", "Common");
        this->addElement("h5", "Heading", "Inline", "Common");
        this->addElement("h6", "Heading", "Inline", "Common");
        // Block Structural -----------------------------------------------
        let p =  this->addElement("p", "Block", "Inline", "Common");
        let tmpArrayc6a2060d1a207c8fdeae528e99c058b6 = ["address", "blockquote", "center", "dir", "div", "dl", "fieldset", "ol", "p", "ul"];
        let p->autoclose =  array_flip(tmpArrayc6a2060d1a207c8fdeae528e99c058b6);
        this->addElement("div", "Block", "Flow", "Common");
    }

}