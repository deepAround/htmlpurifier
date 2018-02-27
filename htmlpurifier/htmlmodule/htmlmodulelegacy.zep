namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\AttrDef\AttrDefInteger;
/**
 * XHTML 1.1 Legacy module defines elements that were previously
 * deprecated.
 *
 * @note Not all legacy elements have been implemented yet, which
 *       is a bit of a reverse problem as compared to browsers! In
 *       addition, this legacy module may implement a bit more than
 *       mandated by XHTML 1.1.
 *
 * This module can be used in combination with TransformToStrict in order
 * to transform as many deprecated elements as possible, but retain
 * questionably deprecated elements that do not have good alternatives
 * as well as transform elements that don't have an implementation.
 * See docs/ref-strictness.txt for more details.
 */
class HTMLModuleLegacy extends HTMLModule
{
    /**
     * @type string
     */
    public name = "Legacy";
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var tmpArray31244cd2c7f566b9a430fb66a113473d, tmpArraybe033168ca15004a779fd66cc3079982, tmpArrayab77e2a01ebd9cf539fa947be7447b1e, tmpArrayed2440e51e7c5136b52e222ea994d815, tmpArray38bbca4906166dc6d9ae595a7d7d1a61, s, strike, u, align, address, blockquote, br, caption, div, dl, i, h, hr, img, li, ol, p, pre, table, tr, th, td, ul, form, input, legend;
    
        let tmpArray31244cd2c7f566b9a430fb66a113473d = ["color" : "Color", "face" : "Text", "size" : "Text", "id" : "ID"];
        this->addElement("basefont", "Inline", "Empty", null, tmpArray31244cd2c7f566b9a430fb66a113473d);
        this->addElement("center", "Block", "Flow", "Common");
        let tmpArraybe033168ca15004a779fd66cc3079982 = ["compact" : "Bool#compact"];
        this->addElement("dir", "Block", "Required: li", "Common", tmpArraybe033168ca15004a779fd66cc3079982);
        let tmpArrayab77e2a01ebd9cf539fa947be7447b1e = ["Core", "I18N"];
        let tmpArrayed2440e51e7c5136b52e222ea994d815 = ["color" : "Color", "face" : "Text", "size" : "Text"];
        this->addElement("font", "Inline", "Inline", tmpArrayab77e2a01ebd9cf539fa947be7447b1e, tmpArrayed2440e51e7c5136b52e222ea994d815);
        let tmpArray38bbca4906166dc6d9ae595a7d7d1a61 = ["compact" : "Bool#compact"];
        this->addElement("menu", "Block", "Required: li", "Common", tmpArray38bbca4906166dc6d9ae595a7d7d1a61);
        let s =  this->addElement("s", "Inline", "Inline", "Common");
        let s->formatting =  true;
        let strike =  this->addElement("strike", "Inline", "Inline", "Common");
        let strike->formatting =  true;
        let u =  this->addElement("u", "Inline", "Inline", "Common");
        let u->formatting =  true;
        // setup modifications to old elements
        let align = "Enum#left,right,center,justify";
        let address =  this->addBlankElement("address");
        let address->content_model = "Inline | #PCDATA | p";
        let address->content_model_type = "optional";
        let address->child =  false;
        let blockquote =  this->addBlankElement("blockquote");
        let blockquote->content_model = "Flow | #PCDATA";
        let blockquote->content_model_type = "optional";
        let blockquote->child =  false;
        let br =  this->addBlankElement("br");
        let br->attr["clear"] = "Enum#left,all,right,none";
        let caption =  this->addBlankElement("caption");
        let caption->attr["align"] = "Enum#top,bottom,left,right";
        let div =  this->addBlankElement("div");
        let div->attr["align"] = align;
        let dl =  this->addBlankElement("dl");
        let dl->attr["compact"] = "Bool#compact";
        let i = 1;
        for i in range(1, 6) {
            let h =  this->addBlankElement("h{i}");
            let h->attr["align"] = align;
        }
        let hr =  this->addBlankElement("hr");
        let hr->attr["align"] = align;
        let hr->attr["noshade"] = "Bool#noshade";
        let hr->attr["size"] = "Pixels";
        let hr->attr["width"] = "Length";
        let img =  this->addBlankElement("img");
        let img->attr["align"] = "IAlign";
        let img->attr["border"] = "Pixels";
        let img->attr["hspace"] = "Pixels";
        let img->attr["vspace"] = "Pixels";
        // figure out this integer business
        let li =  this->addBlankElement("li");
        let li->attr["value"] = new AttrDefInteger();
        let li->attr["type"] = "Enum#s:1,i,I,a,A,disc,square,circle";
        let ol =  this->addBlankElement("ol");
        let ol->attr["compact"] = "Bool#compact";
        let ol->attr["start"] = new AttrDefInteger();
        let ol->attr["type"] = "Enum#s:1,i,I,a,A";
        let p =  this->addBlankElement("p");
        let p->attr["align"] = align;
        let pre =  this->addBlankElement("pre");
        let pre->attr["width"] = "Number";
        // script omitted
        let table =  this->addBlankElement("table");
        let table->attr["align"] = "Enum#left,center,right";
        let table->attr["bgcolor"] = "Color";
        let tr =  this->addBlankElement("tr");
        let tr->attr["bgcolor"] = "Color";
        let th =  this->addBlankElement("th");
        let th->attr["bgcolor"] = "Color";
        let th->attr["height"] = "Length";
        let th->attr["nowrap"] = "Bool#nowrap";
        let th->attr["width"] = "Length";
        let td =  this->addBlankElement("td");
        let td->attr["bgcolor"] = "Color";
        let td->attr["height"] = "Length";
        let td->attr["nowrap"] = "Bool#nowrap";
        let td->attr["width"] = "Length";
        let ul =  this->addBlankElement("ul");
        let ul->attr["compact"] = "Bool#compact";
        let ul->attr["type"] = "Enum#square,disc,circle";
        // "safe" modifications to "unsafe" elements
        // WARNING: If you want to add support for an unsafe, legacy
        // attribute, make a new TrustedLegacy module with the trusted
        // bit set appropriately
        let form =  this->addBlankElement("form");
        let form->content_model = "Flow | #PCDATA";
        let form->content_model_type = "optional";
        let form->attr["target"] = "FrameTarget";
        let input =  this->addBlankElement("input");
        let input->attr["align"] = "IAlign";
        let legend =  this->addBlankElement("legend");
        let legend->attr["align"] = "LAlign";
    }

}