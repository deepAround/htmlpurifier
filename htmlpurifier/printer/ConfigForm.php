<?php
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
    protected $fields = array();

    /**
     * Documentation URL, can have fragment tagged on end.
     * @type string
     */
    protected $docURL;

    /**
     * Name of form element to stuff config in.
     * @type string
     */
    protected $name;

    /**
     * Whether or not to compress directive names, clipping them off
     * after a certain amount of letters. False to disable or integer letters
     * before clipping.
     * @type bool
     */
    protected $compress = false;

    /**
     * @param string $name Form element name for directives to be stuffed into
     * @param string $doc_url String documentation URL, will have fragment tagged on
     * @param bool $compress Integer max length before compressing a directive name, set to false to turn off
     */
    public function __construct(
        $name,
        $doc_url = null,
        $compress = false
    ) {
        parent::__construct();
        $this->docURL = $doc_url;
        $this->name = $name;
        $this->compress = $compress;
        // initialize sub-printers
        $this->fields[0] = new PrinterConfigFormdefault();
        $this->fields[VarParser::BOOL] = new PrinterConfigFormbool();
    }

    /**
     * Sets default column and row size for textareas in sub-printers
     * @param $cols Integer columns of textarea, null to use default
     * @param $rows Integer rows of textarea, null to use default
     */
    public function setTextareaDimensions($cols = null, $rows = null)
    {
        if ($cols) {
            $this->fields['default']->cols = $cols;
        }
        if ($rows) {
            $this->fields['default']->rows = $rows;
        }
    }

    /**
     * Retrieves styling, in case it is not accessible by webserver
     */
    public static function getCSS()
    {
        return file_get_contents(PREFIX . '/HTMLPurifier/Printer/ConfigForm.css');
    }

    /**
     * Retrieves JavaScript, in case it is not accessible by webserver
     */
    public static function getJavaScript()
    {
        return file_get_contents(PREFIX . '/HTMLPurifier/Printer/ConfigForm.js');
    }

    /**
     * Returns HTML output for a configuration form
     * @param Config|array $config Configuration object of current form state, or an array
     *        where [0] has an HTML namespace and [1] is being rendered.
     * @param array|bool $allowed Optional namespace(s) and directives to restrict form to.
     * @param bool $render_controls
     * @return string
     */
    public function render($config, $allowed = true, $render_controls = true)
    {
        if (is_array($config) && isset($config[0])) {
            $gen_config = $config[0];
            $config = $config[1];
        } else {
            $gen_config = $config;
        }

        $this->config = $config;
        $this->genConfig = $gen_config;
        $this->prepareGenerator($gen_config);

        $allowed = Config::getAllowedDirectivesForForm($allowed, $config->def);
        $all = array();
        foreach ($allowed as $key) {
            list($ns, $directive) = $key;
            $all[$ns][$directive] = $config->get($ns . '.' . $directive);
        }

        $ret = '';
        $ret .= $this->start('table', array('class' => 'hp-config'));
        $ret .= $this->start('thead');
        $ret .= $this->start('tr');
        $ret .= $this->element('th', 'Directive', array('class' => 'hp-directive'));
        $ret .= $this->element('th', 'Value', array('class' => 'hp-value'));
        $ret .= $this->end('tr');
        $ret .= $this->end('thead');
        foreach ($all as $ns => $directives) {
            $ret .= $this->renderNamespace($ns, $directives);
        }
        if ($render_controls) {
            $ret .= $this->start('tbody');
            $ret .= $this->start('tr');
            $ret .= $this->start('td', array('colspan' => 2, 'class' => 'controls'));
            $ret .= $this->elementEmpty('input', array('type' => 'submit', 'value' => 'Submit'));
            $ret .= '[<a href="?">Reset</a>]';
            $ret .= $this->end('td');
            $ret .= $this->end('tr');
            $ret .= $this->end('tbody');
        }
        $ret .= $this->end('table');
        return $ret;
    }

    /**
     * Renders a single namespace
     * @param $ns String namespace name
     * @param array $directives array of directives to values
     * @return string
     */
    protected function renderNamespace($ns, $directives)
    {
        $ret = '';
        $ret .= $this->start('tbody', array('class' => 'namespace'));
        $ret .= $this->start('tr');
        $ret .= $this->element('th', $ns, array('colspan' => 2));
        $ret .= $this->end('tr');
        $ret .= $this->end('tbody');
        $ret .= $this->start('tbody');
        foreach ($directives as $directive => $value) {
            $ret .= $this->start('tr');
            $ret .= $this->start('th');
            if ($this->docURL) {
                $url = str_replace('%s', urlencode("$ns.$directive"), $this->docURL);
                $ret .= $this->start('a', array('href' => $url));
            }
            $attr = array('for' => "{$this->name}:$ns.$directive");

            // crop directive name if it's too long
            if (!$this->compress || (strlen($directive) < $this->compress)) {
                $directive_disp = $directive;
            } else {
                $directive_disp = substr($directive, 0, $this->compress - 2) . '...';
                $attr['title'] = $directive;
            }

            $ret .= $this->element(
                'label',
                $directive_disp,
                // component printers must create an element with this id
                $attr
            );
            if ($this->docURL) {
                $ret .= $this->end('a');
            }
            $ret .= $this->end('th');

            $ret .= $this->start('td');
            $def = $this->config->def->info["$ns.$directive"];
            if (is_int($def)) {
                $allow_null = $def < 0;
                $type = abs($def);
            } else {
                $type = $def->type;
                $allow_null = isset($def->allow_null);
            }
            if (!isset($this->fields[$type])) {
                $type = 0;
            } // default
            $type_obj = $this->fields[$type];
            if ($allow_null) {
                $type_obj = new PrinterConfigFormNullDecorator($type_obj);
            }
            $ret .= $type_obj->render($ns, $directive, $value, $this->name, array($this->genConfig, $this->config));
            $ret .= $this->end('td');
            $ret .= $this->end('tr');
        }
        $ret .= $this->end('tbody');
        return $ret;
    }

}




// vim: et sw=4 sts=4
