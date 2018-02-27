<?php
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
	protected $obj;
	
	/**
	 * @param Printer $obj Printer to decorate
	 */
	public function __construct($obj)
	{
		parent::__construct();
		$this->obj = $obj;
	}
	
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
		$ret .= $this->start('label', array('for' => "$name:Null_$ns.$directive"));
		$ret .= $this->element('span', "$ns.$directive:", array('class' => 'verbose'));
		$ret .= $this->text(' Null/Disabled');
		$ret .= $this->end('label');
		$attr = array(
			'type' => 'checkbox',
			'value' => '1',
			'class' => 'null-toggle',
			'name' => "$name" . "[Null_$ns.$directive]",
			'id' => "$name:Null_$ns.$directive",
			'onclick' => "toggleWriteability('$name:$ns.$directive',checked)" // INLINE JAVASCRIPT!!!!
		);
		if ($this->obj instanceof PrinterConfigFormbool) {
			// modify inline javascript slightly
			$attr['onclick'] =
			"toggleWriteability('$name:Yes_$ns.$directive',checked);" .
			"toggleWriteability('$name:No_$ns.$directive',checked)";
		}
		if ($value === null) {
			$attr['checked'] = 'checked';
		}
		$ret .= $this->elementEmpty('input', $attr);
		$ret .= $this->text(' or ');
		$ret .= $this->elementEmpty('br');
		$ret .= $this->obj->render($ns, $directive, $value, $name, array($gen_config, $config));
		return $ret;
	}
}