<?php
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
	public $cols = 18;
	
	/**
	 * @type int
	 */
	public $rows = 5;
	
	/**
	 * @param string $ns
	 * @param string $directive
	 * @param string $value
	 * @param string $name
	 * @param Config|array $config
	 * @return string
	 */
	public function render($ns, $directive, $value, $name, $config)
	{
		if (is_array($config) && isset($config[0])) {
			$gen_config = $config[0];
			$config = $config[1];
		} else {
			$gen_config = $config;
		}
		$this->prepareGenerator($gen_config);
		// this should probably be split up a little
		$ret = '';
		$def = $config->def->info["$ns.$directive"];
		if (is_int($def)) {
			$type = abs($def);
		} else {
			$type = $def->type;
		}
		if (is_array($value)) {
			switch ($type) {
				case VarParser::LOOKUP:
					$array = $value;
					$value = array();
					foreach ($array as $val => $b) {
						$value[] = $val;
					}
					//TODO does this need a break?
				case VarParser::ALIST:
					$value = implode(PHP_EOL, $value);
					break;
				case VarParser::HASH:
					$nvalue = '';
					foreach ($value as $i => $v) {
						if (is_array($v)) {
							// HACK
							$v = implode(";", $v);
						}
						$nvalue .= "$i:$v" . PHP_EOL;
					}
					$value = $nvalue;
					break;
				default:
					$value = '';
			}
		}
		if ($type === VarParser::MIXED) {
			return 'Not supported';
			$value = serialize($value);
		}
		$attr = array(
			'name' => "$name" . "[$ns.$directive]",
			'id' => "$name:$ns.$directive"
		);
		if ($value === null) {
			$attr['disabled'] = 'disabled';
		}
		if (isset($def->allowed)) {
			$ret .= $this->start('select', $attr);
			foreach ($def->allowed as $val => $b) {
				$attr = array();
				if ($value == $val) {
					$attr['selected'] = 'selected';
				}
				$ret .= $this->element('option', $val, $attr);
			}
			$ret .= $this->end('select');
		} elseif ($type === VarParser::TEXT ||
			$type === VarParser::ITEXT ||
			$type === VarParser::ALIST ||
			$type === VarParser::HASH ||
			$type === VarParser::LOOKUP) {
				$attr['cols'] = $this->cols;
				$attr['rows'] = $this->rows;
				$ret .= $this->start('textarea', $attr);
				$ret .= $this->text($value);
				$ret .= $this->end('textarea');
		} else {
			$attr['value'] = $value;
			$attr['type'] = 'text';
			$ret .= $this->elementEmpty('input', $attr);
		}
		return $ret;
	}
}