namespace HTMLPurifier\Printer;

use HTMLPurifier\Config;
use HTMLPurifier\Printer;
use HTMLPurifier\VarParser;
/**
 * @todo Rewrite to use Interchange objects
 */
class PrinterConfigForm extends Printer
{
    /**
     * Printers for specific fields.
     * @type Printer[]
     */
    protected fields = [];
    /**
     * Documentation URL, can have fragment tagged on end.
     * @type string
     */
    protected docURL;
    /**
     * Name of form element to stuff config in.
     * @type string
     */
    protected name;
    /**
     * Whether or not to compress directive names, clipping them off
     * after a certain amount of letters. False to disable or integer letters
     * before clipping.
     * @type bool
     */
    protected compress = false;
    /**
     * @param string $name Form element name for directives to be stuffed into
     * @param string $doc_url String documentation URL, will have fragment tagged on
     * @param bool $compress Integer max length before compressing a directive name, set to false to turn off
     */
    public function __construct(string name, string doc_url = null, bool compress = false) -> void
    {
        parent::__construct();
        let this->docURL = doc_url;
        let this->name = name;
        let this->compress = compress;
        // initialize sub-printers
        let this->fields[0] = new PrinterConfigFormdefault();
        let this->fields[VarParser::BOOL] = new PrinterConfigFormbool();
    }
    
    /**
     * Sets default column and row size for textareas in sub-printers
     * @param $cols Integer columns of textarea, null to use default
     * @param $rows Integer rows of textarea, null to use default
     */
    public function setTextareaDimensions(cols = null, rows = null) -> void
    {
        if cols {
            let this->fields["default"]->cols = cols;
        }
        if rows {
            let this->fields["default"]->rows = rows;
        }
    }
    
    /**
     * Retrieves styling, in case it is not accessible by webserver
     */
    public static function getCSS()
    {
        return file_get_contents(PREFIX . "/HTMLPurifier/Printer/ConfigForm.css");
    }
    
    /**
     * Retrieves JavaScript, in case it is not accessible by webserver
     */
    public static function getJavaScript()
    {
        return file_get_contents(PREFIX . "/HTMLPurifier/Printer/ConfigForm.js");
    }
    
    /**
     * Returns HTML output for a configuration form
     * @param Config|array $config Configuration object of current form state, or an array
     *        where [0] has an HTML namespace and [1] is being rendered.
     * @param array|bool $allowed Optional namespace(s) and directives to restrict form to.
     * @param bool $render_controls
     * @return string
     */
    public function render(config, allowed = true, bool render_controls = true) -> string
    {
        var gen_config, all, key, ns, directive, tmpListNsDirective, ret, tmpArraybb04ed5d30e6568aea695533ded2d909, tmpArray9d19cf8b383fc6adde248123885026c1, tmpArray025ef37c0e9d606180209c31d93fbbac, directives, tmpArray2ca4d28c241dad5b7337b924b43014fb, tmpArray8191ac7f78e419e71653a16c076293b5;
    
        if is_array(config) && isset config[0] {
            let gen_config = config[0];
            let config = config[1];
        } else {
            let gen_config = config;
        }
        let this->config = config;
        let this->genConfig = gen_config;
        this->prepareGenerator(gen_config);
        let allowed =  Config::getAllowedDirectivesForForm(allowed, config->def);
        let all =  [];
        for key in allowed {
            let tmpListNsDirective = key;
            let ns = tmpListNsDirective[0];
            let directive = tmpListNsDirective[1];
            let all[ns][directive] =  config->get(ns . "." . directive);
        }
        let ret = "";
        let ret .= let tmpArraybb04ed5d30e6568aea695533ded2d909 = ["class" : "hp-config"];
        this->start("table", tmpArraybb04ed5d30e6568aea695533ded2d909);
        let ret .= this->start("thead");
        let ret .= this->start("tr");
        let ret .= let tmpArray9d19cf8b383fc6adde248123885026c1 = ["class" : "hp-directive"];
        this->element("th", "Directive", tmpArray9d19cf8b383fc6adde248123885026c1);
        let ret .= let tmpArray025ef37c0e9d606180209c31d93fbbac = ["class" : "hp-value"];
        this->element("th", "Value", tmpArray025ef37c0e9d606180209c31d93fbbac);
        let ret .= this->end("tr");
        let ret .= this->end("thead");
        for ns, directives in all {
            let ret .= this->renderNamespace(ns, directives);
        }
        if render_controls {
            let ret .= this->start("tbody");
            let ret .= this->start("tr");
            let ret .= let tmpArray2ca4d28c241dad5b7337b924b43014fb = ["colspan" : 2, "class" : "controls"];
            this->start("td", tmpArray2ca4d28c241dad5b7337b924b43014fb);
            let ret .= let tmpArray8191ac7f78e419e71653a16c076293b5 = ["type" : "submit", "value" : "Submit"];
            this->elementEmpty("input", tmpArray8191ac7f78e419e71653a16c076293b5);
            let ret .= "[<a href=\"?\">Reset</a>]";
            let ret .= this->end("td");
            let ret .= this->end("tr");
            let ret .= this->end("tbody");
        }
        let ret .= this->end("table");
        return ret;
    }
    
    /**
     * Renders a single namespace
     * @param $ns String namespace name
     * @param array $directives array of directives to values
     * @return string
     */
    protected function renderNamespace(ns, array directives) -> string
    {
        var ret, tmpArray9360208056caac99e3e3ed708c03f23f, tmpArrayf249bd59011191af97fc526115abd26f, directive, value, url, tmpArraye4a001cccf89028e7b3332a60097d0a1, attr, directive_disp, def, allow_null, type, type_obj, tmpArray239135ff20cf7ca7d9f3b390fd99c5d5;
    
        let ret = "";
        let ret .= let tmpArray9360208056caac99e3e3ed708c03f23f = ["class" : "namespace"];
        this->start("tbody", tmpArray9360208056caac99e3e3ed708c03f23f);
        let ret .= this->start("tr");
        let ret .= let tmpArrayf249bd59011191af97fc526115abd26f = ["colspan" : 2];
        this->element("th", ns, tmpArrayf249bd59011191af97fc526115abd26f);
        let ret .= this->end("tr");
        let ret .= this->end("tbody");
        let ret .= this->start("tbody");
        for directive, value in directives {
            let ret .= this->start("tr");
            let ret .= this->start("th");
            if this->docURL {
                let url =  str_replace("%s", urlencode("{ns}.{directive}"), this->docURL);
                let ret .= let tmpArraye4a001cccf89028e7b3332a60097d0a1 = ["href" : url];
                this->start("a", tmpArraye4a001cccf89028e7b3332a60097d0a1);
            }
            let attr =  ["for" : "{this->name}:{ns}.{directive}"];
            // crop directive name if it's too long
            if !(this->compress) || strlen(directive) < this->compress {
                let directive_disp = directive;
            } else {
                let directive_disp =  substr(directive, 0, this->compress - 2) . "...";
                let attr["title"] = directive;
            }
            let ret .= this->element("label", directive_disp, attr);
            if this->docURL {
                let ret .= this->end("a");
            }
            let ret .= this->end("th");
            let ret .= this->start("td");
            let def = this->config->def->info["{ns}.{directive}"];
            if is_int(def) {
                let allow_null =  def < 0;
                let type =  abs(def);
            } else {
                let type =  def->type;
                let allow_null =  isset def->allow_null;
            }
            if !(isset this->fields[type]) {
                let type = 0;
            }
            // default
            let type_obj = this->fields[type];
            if allow_null {
                let type_obj =  new PrinterConfigFormNullDecorator(type_obj);
            }
            let ret .= let tmpArray239135ff20cf7ca7d9f3b390fd99c5d5 = [this->genConfig, this->config];
            type_obj->render(ns, directive, value, this->name, tmpArray239135ff20cf7ca7d9f3b390fd99c5d5);
            let ret .= this->end("td");
            let ret .= this->end("tr");
        }
        let ret .= this->end("tbody");
        return ret;
    }

}