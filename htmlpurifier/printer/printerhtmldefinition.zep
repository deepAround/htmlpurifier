namespace HTMLPurifier\Printer;

use HTMLPurifier\Context;
use HTMLPurifier\Printer;
class PrinterHTMLDefinition extends Printer
{
    /**
     * @type HTMLDefinition, for easy access
     */
    protected def;
    /**
     * @param Config $config
     * @return string
     */
    public function render(<Config> config) -> string
    {
        var ret, tmpArray98ede9b88b585f16fb91521334513b29;
    
        let ret = "";
        let this->config = config;
        let this->def =  config->getHTMLDefinition();
        let ret .= let tmpArray98ede9b88b585f16fb91521334513b29 = ["class" : "Printer"];
        this->start("div", tmpArray98ede9b88b585f16fb91521334513b29);
        let ret .= this->renderDoctype();
        let ret .= this->renderEnvironment();
        let ret .= this->renderContentSets();
        let ret .= this->renderInfo();
        let ret .= this->end("div");
        return ret;
    }
    
    /**
     * Renders the Doctype table
     * @return string
     */
    protected function renderDoctype() -> string
    {
        var doctype, ret;
    
        let doctype =  this->def->doctype;
        let ret = "";
        let ret .= this->start("table");
        let ret .= this->element("caption", "Doctype");
        let ret .= this->row("Name", doctype->name);
        let ret .= this->row("XML",  doctype->xml ? "Yes"  : "No");
        let ret .= this->row("Default Modules", implode(doctype->modules, ", "));
        let ret .= this->row("Default Tidy Modules", implode(doctype->tidyModules, ", "));
        let ret .= this->end("table");
        return ret;
    }
    
    /**
     * Renders environment table, which is miscellaneous info
     * @return string
     */
    protected function renderEnvironment() -> string
    {
        var def, ret, list, old, new;
    
        let def =  this->def;
        let ret = "";
        let ret .= this->start("table");
        let ret .= this->element("caption", "Environment");
        let ret .= this->row("Parent of fragment", def->info_parent);
        let ret .= this->renderChildren(def->info_parent_def->child);
        let ret .= this->row("Block wrap name", def->info_block_wrapper);
        let ret .= this->start("tr");
        let ret .= this->element("th", "Global attributes");
        let ret .= this->element("td", this->listifyAttr(def->info_global_attr), null, 0);
        let ret .= this->end("tr");
        let ret .= this->start("tr");
        let ret .= this->element("th", "Tag transforms");
        let list =  [];
        for old, new in def->info_tag_transform {
            let new =  this->getClass(new, "TagTransform_");
            let list[] = "<{old}> with {new}";
        }
        let ret .= this->element("td", this->listify(list));
        let ret .= this->end("tr");
        let ret .= this->start("tr");
        let ret .= this->element("th", "Pre-AttrTransform");
        let ret .= this->element("td", this->listifyObjectList(def->info_attr_transform_pre));
        let ret .= this->end("tr");
        let ret .= this->start("tr");
        let ret .= this->element("th", "Post-AttrTransform");
        let ret .= this->element("td", this->listifyObjectList(def->info_attr_transform_post));
        let ret .= this->end("tr");
        let ret .= this->end("table");
        return ret;
    }
    
    /**
     * Renders the Content Sets table
     * @return string
     */
    protected function renderContentSets() -> string
    {
        var ret, name, lookup;
    
        let ret = "";
        let ret .= this->start("table");
        let ret .= this->element("caption", "Content Sets");
        for name, lookup in this->def->info_content_sets {
            let ret .= this->heavyHeader(name);
            let ret .= this->start("tr");
            let ret .= this->element("td", this->listifyTagLookup(lookup));
            let ret .= this->end("tr");
        }
        let ret .= this->end("table");
        return ret;
    }
    
    /**
     * Renders the Elements ($info) table
     * @return string
     */
    protected function renderInfo() -> string
    {
        var ret, tmpArrayd13860f2ac1f5558ec7e34ba6550b0c6, name, def, tmpArray6dfe21dfafe7e926f60f251bbdd1bde5, tmpArray40cd750bba9870f18aada2478b24840a;
    
        let ret = "";
        let ret .= this->start("table");
        let ret .= this->element("caption", "Elements ($info)");
        ksort(this->def->info);
        let ret .= this->heavyHeader("Allowed tags", 2);
        let ret .= this->start("tr");
        let ret .= let tmpArrayd13860f2ac1f5558ec7e34ba6550b0c6 = ["colspan" : 2];
        this->element("td", this->listifyTagLookup(this->def->info), tmpArrayd13860f2ac1f5558ec7e34ba6550b0c6);
        let ret .= this->end("tr");
        for name, def in this->def->info {
            let ret .= this->start("tr");
            let ret .= let tmpArray6dfe21dfafe7e926f60f251bbdd1bde5 = ["class" : "heavy", "colspan" : 2];
            this->element("th", "<{name}>", tmpArray6dfe21dfafe7e926f60f251bbdd1bde5);
            let ret .= this->end("tr");
            let ret .= this->start("tr");
            let ret .= this->element("th", "Inline content");
            let ret .= this->element("td",  def->descendants_are_inline ? "Yes"  : "No");
            let ret .= this->end("tr");
            if !(empty(def->excludes)) {
                let ret .= this->start("tr");
                let ret .= this->element("th", "Excludes");
                let ret .= this->element("td", this->listifyTagLookup(def->excludes));
                let ret .= this->end("tr");
            }
            if !(empty(def->attr_transform_pre)) {
                let ret .= this->start("tr");
                let ret .= this->element("th", "Pre-AttrTransform");
                let ret .= this->element("td", this->listifyObjectList(def->attr_transform_pre));
                let ret .= this->end("tr");
            }
            if !(empty(def->attr_transform_post)) {
                let ret .= this->start("tr");
                let ret .= this->element("th", "Post-AttrTransform");
                let ret .= this->element("td", this->listifyObjectList(def->attr_transform_post));
                let ret .= this->end("tr");
            }
            if !(empty(def->auto_close)) {
                let ret .= this->start("tr");
                let ret .= this->element("th", "Auto closed by");
                let ret .= this->element("td", this->listifyTagLookup(def->auto_close));
                let ret .= this->end("tr");
            }
            let ret .= this->start("tr");
            let ret .= this->element("th", "Allowed attributes");
            let ret .= let tmpArray40cd750bba9870f18aada2478b24840a = [];
            this->element("td", this->listifyAttr(def->attr), tmpArray40cd750bba9870f18aada2478b24840a, 0);
            let ret .= this->end("tr");
            if !(empty(def->required_attr)) {
                let ret .= this->row("Required attributes", this->listify(def->required_attr));
            }
            let ret .= this->renderChildren(def->child);
        }
        let ret .= this->end("table");
        return ret;
    }
    
    /**
     * Renders a row describing the allowed children of an element
     * @param ChildDef $def ChildDef of pertinent element
     * @return string
     */
    protected function renderChildren(<ChildDef> def) -> string
    {
        var context, ret, elements, attr, tmpArray40cd750bba9870f18aada2478b24840a, tmpArray9ad1371e6bace07c7a6bdf3c4e01bcaa;
    
        let context =  new Context();
        let ret = "";
        let ret .= this->start("tr");
        let elements =  [];
        let attr =  [];
        if isset def->elements {
            if def->type == "strictblockquote" {
                let tmpArray40cd750bba9870f18aada2478b24840a = [];
                def->validateChildren(tmpArray40cd750bba9870f18aada2478b24840a, this->config, context);
            }
            let elements =  def->elements;
        }
        if def->type == "chameleon" {
            let attr["rowspan"] = 2;
        } elseif def->type == "empty" {
            let elements =  [];
        } elseif def->type == "table" {
            let tmpArray9ad1371e6bace07c7a6bdf3c4e01bcaa = ["col", "caption", "colgroup", "thead", "tfoot", "tbody", "tr"];
            let elements =  array_flip(tmpArray9ad1371e6bace07c7a6bdf3c4e01bcaa);
        }
        let ret .= this->element("th", "Allowed children", attr);
        if def->type == "chameleon" {
            let ret .= this->element("td", "<em>Block</em>: " . this->escape(this->listifyTagLookup(def->block->elements)), null, 0);
            let ret .= this->end("tr");
            let ret .= this->start("tr");
            let ret .= this->element("td", "<em>Inline</em>: " . this->escape(this->listifyTagLookup(def->inlinee->elements)), null, 0);
        } elseif def->type == "custom" {
            let ret .= this->element("td", "<em>" . ucfirst(def->type) . "</em>: " . def->dtd_regex);
        } else {
            let ret .= this->element("td", "<em>" . ucfirst(def->type) . "</em>: " . this->escape(this->listifyTagLookup(elements)), null, 0);
        }
        let ret .= this->end("tr");
        return ret;
    }
    
    /**
     * Listifies a tag lookup table.
     * @param array $array Tag lookup array in form of array('tagname' => true)
     * @return string
     */
    protected function listifyTagLookup(array myArray) -> string
    {
        var list, name, discard;
    
        ksort(myArray);
        let list =  [];
        for name, discard in myArray {
            if name !== "#PCDATA" && !(isset this->def->info[name]) {
                continue;
            }
            let list[] = name;
        }
        return this->listify(list);
    }
    
    /**
     * Listifies a list of objects by retrieving class names and internal state
     * @param array $array List of objects
     * @return string
     * @todo Also add information about internal state
     */
    protected function listifyObjectList(array myArray) -> string
    {
        var list, obj;
    
        ksort(myArray);
        let list =  [];
        for obj in myArray {
            let list[] =  this->getClass(obj, "AttrTransform_");
        }
        return this->listify(list);
    }
    
    /**
     * Listifies a hash of attributes to AttrDef classes
     * @param array $array Array hash in form of array('attrname' => AttrDef)
     * @return string
     */
    protected function listifyAttr(array myArray) -> string
    {
        var list, name, obj;
    
        ksort(myArray);
        let list =  [];
        for name, obj in myArray {
            if obj === false {
                continue;
            }
            let list[] =  "{name}&nbsp;=&nbsp;<i>" . this->getClass(obj, "AttrDef_") . "</i>";
        }
        return this->listify(list);
    }
    
    /**
     * Creates a heavy header row
     * @param string $text
     * @param int $num
     * @return string
     */
    protected function heavyHeader(string text, int num = 1) -> string
    {
        var ret, tmpArraydcce3e46871f6a23e16adbf5f7525fa1;
    
        let ret = "";
        let ret .= this->start("tr");
        let ret .= let tmpArraydcce3e46871f6a23e16adbf5f7525fa1 = ["colspan" : num, "class" : "heavy"];
        this->element("th", text, tmpArraydcce3e46871f6a23e16adbf5f7525fa1);
        let ret .= this->end("tr");
        return ret;
    }

}