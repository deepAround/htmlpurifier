namespace HTMLPurifier\Printer;

use HTMLPurifier\Printer;
class PrinterCSSDefinition extends Printer
{
    /**
     * @type CSSDefinition
     */
    protected def;
    /**
     * @param Config $config
     * @return string
     */
    public function render(<Config> config) -> string
    {
        var ret, tmpArraya7a5b77785aef02d4fb1f3ac3aac2ed3, tmpArray274d17b0fa373f9cbbe6ff3627053368, tmpArray87bb3200f94e0ab07d359fd11594cf8f, property, obj, name;
    
        let this->def =  config->getCSSDefinition();
        let ret = "";
        let ret .= let tmpArraya7a5b77785aef02d4fb1f3ac3aac2ed3 = ["class" : "Printer"];
        this->start("div", tmpArraya7a5b77785aef02d4fb1f3ac3aac2ed3);
        let ret .= this->start("table");
        let ret .= this->element("caption", "Properties ($info)");
        let ret .= this->start("thead");
        let ret .= this->start("tr");
        let ret .= let tmpArray274d17b0fa373f9cbbe6ff3627053368 = ["class" : "heavy"];
        this->element("th", "Property", tmpArray274d17b0fa373f9cbbe6ff3627053368);
        let ret .= let tmpArray87bb3200f94e0ab07d359fd11594cf8f = ["class" : "heavy", "style" : "width:auto;"];
        this->element("th", "Definition", tmpArray87bb3200f94e0ab07d359fd11594cf8f);
        let ret .= this->end("tr");
        let ret .= this->end("thead");
        ksort(this->def->info);
        for property, obj in this->def->info {
            let name =  this->getClass(obj, "AttrDef_");
            let ret .= this->row(property, name);
        }
        let ret .= this->end("table");
        let ret .= this->end("div");
        return ret;
    }

}