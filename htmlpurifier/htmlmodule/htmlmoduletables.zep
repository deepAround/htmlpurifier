namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\ChildDef\ChildDefTable;
/**
 * XHTML 1.1 Tables Module, fully defines accessible table elements.
 */
class HTMLModuleTables extends HTMLModule
{
    /**
     * @type string
     */
    public name = "Tables";
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var tmpArray4aceda583ab8bbff4b776371e766ec5b, cell_align, cell_t, tmpArray9659e3a4f491f3cc918f4583c4df4395, cell_col, tmpArray717a11f7f2cbbb75300a7d3554535060;
    
        this->addElement("caption", false, "Inline", "Common");
        let tmpArray4aceda583ab8bbff4b776371e766ec5b = ["border" : "Pixels", "cellpadding" : "Length", "cellspacing" : "Length", "frame" : "Enum#void,above,below,hsides,lhs,rhs,vsides,box,border", "rules" : "Enum#none,groups,rows,cols,all", "summary" : "Text", "width" : "Length"];
        this->addElement("table", "Block", new ChildDefTable(), "Common", tmpArray4aceda583ab8bbff4b776371e766ec5b);
        // common attributes
        let cell_align =  ["align" : "Enum#left,center,right,justify,char", "charoff" : "Length", "valign" : "Enum#top,middle,bottom,baseline"];
        let tmpArray9659e3a4f491f3cc918f4583c4df4395 = ["abbr" : "Text", "colspan" : "Number", "rowspan" : "Number", "scope" : "Enum#row,col,rowgroup,colgroup"];
        let cell_t =  array_merge(tmpArray9659e3a4f491f3cc918f4583c4df4395, cell_align);
        this->addElement("td", false, "Flow", "Common", cell_t);
        this->addElement("th", false, "Flow", "Common", cell_t);
        this->addElement("tr", false, "Required: td | th", "Common", cell_align);
        let tmpArray717a11f7f2cbbb75300a7d3554535060 = ["span" : "Number", "width" : "MultiLength"];
        let cell_col =  array_merge(tmpArray717a11f7f2cbbb75300a7d3554535060, cell_align);
        this->addElement("col", false, "Empty", "Common", cell_col);
        this->addElement("colgroup", false, "Optional: col", "Common", cell_col);
        this->addElement("tbody", false, "Required: tr", "Common", cell_align);
        this->addElement("thead", false, "Required: tr", "Common", cell_align);
        this->addElement("tfoot", false, "Required: tr", "Common", cell_align);
    }

}