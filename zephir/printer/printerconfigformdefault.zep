namespace HTMLPurifier\Printer;

use HTMLPurifier\Printer;
/**
 * Swiss-army knife configuration form field printer
 */
class PrinterConfigFormdefault extends Printer
{
    /**
     * @type int
     */
    public cols = 18;
    /**
     * @type int
     */
    public rows = 5;
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
        var gen_config, ret, def, type, myArray, val, b, nvalue, i, v, attr;
    
        if is_array(config) && isset config[0] {
            let gen_config = config[0];
            let config = config[1];
        } else {
            let gen_config = config;
        }
        this->prepareGenerator(gen_config);
        // this should probably be split up a little
        let ret = "";
        let def = config->def->info["{ns}.{directive}"];
        if is_int(def) {
            let type =  abs(def);
        } else {
            let type =  def->type;
        }
        if is_array(value) {
            if VarParser::LOOKUP {
                let myArray = value;
                let value =  [];
                for val, b in myArray {
                    let value[] = val;
                }
            } elseif VarParser::HASH {
                let nvalue = "";
                for i, v in value {
                    if is_array(v) {
                        // HACK
                        let v =  implode(";", v);
                    }
                    let nvalue .= "{i}:{v}" . PHP_EOL;
                }
                let value = nvalue;
            } elseif VarParser::ALIST {
                let value =  implode(PHP_EOL, value);
            } else {
                let value = "";
            }
        }
        if type === VarParser::MIXED {
            return "Not supported";
            let value =  serialize(value);
        }
        let attr =  ["name" : "{name}" . "[{ns}.{directive}]", "id" : "{name}:{ns}.{directive}"];
        if value === null {
            let attr["disabled"] = "disabled";
        }
        if isset def->allowed {
            let ret .= this->start("select", attr);
            for val, b in def->allowed {
                let attr =  [];
                if value == val {
                    let attr["selected"] = "selected";
                }
                let ret .= this->element("option", val, attr);
            }
            let ret .= this->end("select");
        } elseif type === VarParser::TEXT || type === VarParser::ITEXT || type === VarParser::ALIST || type === VarParser::HASH || type === VarParser::LOOKUP {
            let attr["cols"] = this->cols;
            let attr["rows"] = this->rows;
            let ret .= this->start("textarea", attr);
            let ret .= this->text(value);
            let ret .= this->end("textarea");
        } else {
            let attr["value"] = value;
            let attr["type"] = "text";
            let ret .= this->elementEmpty("input", attr);
        }
        return ret;
    }

}