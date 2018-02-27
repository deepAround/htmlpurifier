namespace HTMLPurifier\Printer;

use HTMLPurifier\Printer;
/**
 * Bool form field printer
 */
class PrinterConfigFormbool extends Printer
{
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
        var gen_config, ret, tmpArraybde10b4183e49205b458c21254fbd057, tmpArrayc3e5ba4c16ef9558c2d20b40c03977dc, tmpArray3e37c94b7c1342ad02bac94468277ec9, attr, tmpArray674ec65ed8af39f0a2fd933848e9da93, tmpArray35d75a964e1e1202405441494820c87f;
    
        if is_array(config) && isset config[0] {
            let gen_config = config[0];
            let config = config[1];
        } else {
            let gen_config = config;
        }
        this->prepareGenerator(gen_config);
        let ret = "";
        let ret .= let tmpArraybde10b4183e49205b458c21254fbd057 = ["id" : "{name}:{ns}.{directive}"];
        this->start("div", tmpArraybde10b4183e49205b458c21254fbd057);
        let ret .= let tmpArrayc3e5ba4c16ef9558c2d20b40c03977dc = ["for" : "{name}:Yes_{ns}.{directive}"];
        this->start("label", tmpArrayc3e5ba4c16ef9558c2d20b40c03977dc);
        let ret .= let tmpArray3e37c94b7c1342ad02bac94468277ec9 = ["class" : "verbose"];
        this->element("span", "{ns}.{directive}:", tmpArray3e37c94b7c1342ad02bac94468277ec9);
        let ret .= this->text(" Yes");
        let ret .= this->end("label");
        let attr =  ["type" : "radio", "name" : "{name}" . "[{ns}.{directive}]", "id" : "{name}:Yes_{ns}.{directive}", "value" : "1"];
        if value === true {
            let attr["checked"] = "checked";
        }
        if value === null {
            let attr["disabled"] = "disabled";
        }
        let ret .= this->elementEmpty("input", attr);
        let ret .= let tmpArray674ec65ed8af39f0a2fd933848e9da93 = ["for" : "{name}:No_{ns}.{directive}"];
        this->start("label", tmpArray674ec65ed8af39f0a2fd933848e9da93);
        let ret .= let tmpArray35d75a964e1e1202405441494820c87f = ["class" : "verbose"];
        this->element("span", "{ns}.{directive}:", tmpArray35d75a964e1e1202405441494820c87f);
        let ret .= this->text(" No");
        let ret .= this->end("label");
        let attr =  ["type" : "radio", "name" : "{name}" . "[{ns}.{directive}]", "id" : "{name}:No_{ns}.{directive}", "value" : "0"];
        if value === false {
            let attr["checked"] = "checked";
        }
        if value === null {
            let attr["disabled"] = "disabled";
        }
        let ret .= this->elementEmpty("input", attr);
        let ret .= this->end("div");
        return ret;
    }

}