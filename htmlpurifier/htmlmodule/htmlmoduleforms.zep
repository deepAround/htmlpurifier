namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\AttrTransform\AttrTransformInput;
use HTMLPurifier\AttrTransform\AttrTransformTextarea;
/**
 * XHTML 1.1 Forms module, defines all form-related elements found in HTML 4.
 */
class HTMLModuleForms extends HTMLModule
{
    /**
     * @type string
     */
    public name = "Forms";
    /**
     * @type bool
     */
    public safe = false;
    /**
     * @type array
     */
    public content_sets = ["Block" : "Form", "Inline" : "Formctrl"];
    /**
     * @param Config $config
     */
    public function setup(<Config> config) -> void
    {
        var form, tmpArray00a7e73c643ccdbcca7dbd9b36342176, input, tmpArray032c778e1f51a5d563e8dcef20c73213, tmpArray2389afc17337f2bc6ff4f6b9b5c41b17, tmpArray6e9557de2410111ed1ea3fd8a21cc3f8, textarea, tmpArrayb57f6e2d7fe5512accdf5bdcc20fa2f8, button, tmpArray48de87305d835835bd567c1b83dcb909, label, tmpArrayc298bebbd4338140dc269b94881e9ca2, tmpArrayc8400441e28a70a1ce5f45fb427277ef, tmpArray9d1ab4400d13b7beee63d3f3c66dd5ad;
    
        let tmpArray00a7e73c643ccdbcca7dbd9b36342176 = ["accept" : "ContentTypes", "accept-charset" : "Charsets", "action*" : "URI", "method" : "Enum#get,post", "enctype" : "Enum#application/x-www-form-urlencoded,multipart/form-data"];
        let form =  this->addElement("form", "Form", "Required: Heading | List | Block | fieldset", "Common", tmpArray00a7e73c643ccdbcca7dbd9b36342176);
        let form->excludes =  ["form" : true];
        let tmpArray032c778e1f51a5d563e8dcef20c73213 = ["accept" : "ContentTypes", "accesskey" : "Character", "alt" : "Text", "checked" : "Bool#checked", "disabled" : "Bool#disabled", "maxlength" : "Number", "name" : "CDATA", "readonly" : "Bool#readonly", "size" : "Number", "src" : "URI#embedded", "tabindex" : "Number", "type" : "Enum#text,password,checkbox,button,radio,submit,reset,file,hidden,image", "value" : "CDATA"];
        let input =  this->addElement("input", "Formctrl", "Empty", "Common", tmpArray032c778e1f51a5d563e8dcef20c73213);
        let input->attr_transform_post[] = new AttrTransformInput();
        let tmpArray2389afc17337f2bc6ff4f6b9b5c41b17 = ["disabled" : "Bool#disabled", "multiple" : "Bool#multiple", "name" : "CDATA", "size" : "Number", "tabindex" : "Number"];
        this->addElement("select", "Formctrl", "Required: optgroup | option", "Common", tmpArray2389afc17337f2bc6ff4f6b9b5c41b17);
        let tmpArray6e9557de2410111ed1ea3fd8a21cc3f8 = ["disabled" : "Bool#disabled", "label" : "Text", "selected" : "Bool#selected", "value" : "CDATA"];
        this->addElement("option", false, "Optional: #PCDATA", "Common", tmpArray6e9557de2410111ed1ea3fd8a21cc3f8);
        // It's illegal for there to be more than one selected, but not
        // be multiple. Also, no selected means undefined behavior. This might
        // be difficult to implement; perhaps an injector, or a context variable.
        let tmpArrayb57f6e2d7fe5512accdf5bdcc20fa2f8 = ["accesskey" : "Character", "cols*" : "Number", "disabled" : "Bool#disabled", "name" : "CDATA", "readonly" : "Bool#readonly", "rows*" : "Number", "tabindex" : "Number"];
        let textarea =  this->addElement("textarea", "Formctrl", "Optional: #PCDATA", "Common", tmpArrayb57f6e2d7fe5512accdf5bdcc20fa2f8);
        let textarea->attr_transform_pre[] = new AttrTransformTextarea();
        let tmpArray48de87305d835835bd567c1b83dcb909 = ["accesskey" : "Character", "disabled" : "Bool#disabled", "name" : "CDATA", "tabindex" : "Number", "type" : "Enum#button,submit,reset", "value" : "CDATA"];
        let button =  this->addElement("button", "Formctrl", "Optional: #PCDATA | Heading | List | Block | Inline", "Common", tmpArray48de87305d835835bd567c1b83dcb909);
        // For exclusions, ideally we'd specify content sets, not literal elements
        let button->excludes =  this->makeLookup("form", "fieldset", "input", "select", "textarea", "label", "button", "a", "isindex", "iframe");
        // Extra exclusion: img usemap="" is not permitted within this element.
        // We'll omit this for now, since we don't have any good way of
        // indicating it yet.
        // This is HIGHLY user-unfriendly; we need a custom child-def for this
        this->addElement("fieldset", "Form", "Custom: (#WS?,legend,(Flow|#PCDATA)*)", "Common");
        let tmpArrayc298bebbd4338140dc269b94881e9ca2 = ["accesskey" : "Character"];
        let label =  this->addElement("label", "Formctrl", "Optional: #PCDATA | Inline", "Common", tmpArrayc298bebbd4338140dc269b94881e9ca2);
        let label->excludes =  ["label" : true];
        let tmpArrayc8400441e28a70a1ce5f45fb427277ef = ["accesskey" : "Character"];
        this->addElement("legend", false, "Optional: #PCDATA | Inline", "Common", tmpArrayc8400441e28a70a1ce5f45fb427277ef);
        let tmpArray9d1ab4400d13b7beee63d3f3c66dd5ad = ["disabled" : "Bool#disabled", "label*" : "Text"];
        this->addElement("optgroup", false, "Required: option", "Common", tmpArray9d1ab4400d13b7beee63d3f3c66dd5ad);
    }

}