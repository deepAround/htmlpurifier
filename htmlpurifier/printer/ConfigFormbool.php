<?php
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
	public function render($ns, $directive, $value, $name, $config)
	{
		if (is_array($config) && isset($config[0])) {
			$gen_config = $config[0];
			$config = $config[1];
		} else {
			$gen_config = $config;
		}
		$this->prepareGenerator($gen_config);
		$ret = '';
		$ret .= $this->start('div', array('id' => "$name:$ns.$directive"));
		
		$ret .= $this->start('label', array('for' => "$name:Yes_$ns.$directive"));
		$ret .= $this->element('span', "$ns.$directive:", array('class' => 'verbose'));
		$ret .= $this->text(' Yes');
		$ret .= $this->end('label');
		
		$attr = array(
			'type' => 'radio',
			'name' => "$name" . "[$ns.$directive]",
			'id' => "$name:Yes_$ns.$directive",
			'value' => '1'
		);
		if ($value === true) {
			$attr['checked'] = 'checked';
		}
		if ($value === null) {
			$attr['disabled'] = 'disabled';
		}
		$ret .= $this->elementEmpty('input', $attr);
		
		$ret .= $this->start('label', array('for' => "$name:No_$ns.$directive"));
		$ret .= $this->element('span', "$ns.$directive:", array('class' => 'verbose'));
		$ret .= $this->text(' No');
		$ret .= $this->end('label');
		
		$attr = array(
			'type' => 'radio',
			'name' => "$name" . "[$ns.$directive]",
			'id' => "$name:No_$ns.$directive",
			'value' => '0'
		);
		if ($value === false) {
			$attr['checked'] = 'checked';
		}
		if ($value === null) {
			$attr['disabled'] = 'disabled';
		}
		$ret .= $this->elementEmpty('input', $attr);
		
		$ret .= $this->end('div');
		
		return $ret;
	}
}