namespace HTMLPurifier\Printer;

use HTMLPurifier\Printer;
/**
 * Printer decorator for directives that accept null
 */
class PrinterConfigFormNullDecorator extends Printer
{
    /**
     * Printer being decorated
     * @type Printer
     */
    protected obj;
    /**
     * @param Printer $obj Printer to decorate
     */
    public function __construct(<Printer> obj) -> void
    {
        parent::__construct();
        let this->obj = obj;
    }
    
    /**
     * @param string $ns
     * @param string $directive
     * @param string $value
     * @param string $name
     * @param Config|array $config
     * @return string
     */
    public function render(string ns, string directive, string value, string name, config) -> string
    {
        var gen_config, ret, tmpArray3ecf33ca15fb58068aeca7afc33e1312, tmpArrayafe812ff3220128fa16a2710719c340c, attr, tmpArrayd7f6bbaf246b28c2459253b6f52596fd;
    
        if is_array(config) && isset config[0] {
            let gen_config = config[0];
            let config = config[1];
        } else {
            let gen_config = config;
        }
        this->prepareGenerator(gen_config);
        let ret = "";
        let ret .= let tmpArray3ecf33ca15fb58068aeca7afc33e1312 = ["for" : "{name}:Null_{ns}.{directive}"];
        this->start("label", tmpArray3ecf33ca15fb58068aeca7afc33e1312);
        let ret .= let tmpArrayafe812ff3220128fa16a2710719c340c = ["class" : "verbose"];
        this->element("span", "{ns}.{directive}:", tmpArrayafe812ff3220128fa16a2710719c340c);
        let ret .= this->text(" Null/Disabled");
        let ret .= this->end("label");
        let attr =  ["type" : "checkbox", "value" : "1", "class" : "null-toggle", "name" : "{name}" . "[Null_{ns}.{directive}]", "id" : "{name}:Null_{ns}.{directive}", "onclick" : "toggleWriteability('{name}:{ns}.{directive}',checked)"];
        if this->obj instanceof PrinterConfigFormbool {
            // modify inline javascript slightly
            let attr["onclick"] =  "toggleWriteability('{name}:Yes_{ns}.{directive}',checked);" . "toggleWriteability('{name}:No_{ns}.{directive}',checked)";
        }
        if value === null {
            let attr["checked"] = "checked";
        }
        let ret .= this->elementEmpty("input", attr);
        let ret .= this->text(" or ");
        let ret .= this->elementEmpty("br");
        let ret .= let tmpArrayd7f6bbaf246b28c2459253b6f52596fd = [gen_config, config];
        this->obj->render(ns, directive, value, name, tmpArrayd7f6bbaf246b28c2459253b6f52596fd);
        return ret;
    }

}