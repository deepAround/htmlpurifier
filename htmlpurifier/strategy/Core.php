<?php
namespace HTMLPurifier\Strategy;

/**
 * Core strategy composed of the big four strategies.
 */
class StrategyCore extends StrategyComposite
{
    public function __construct()
    {
	    	$this->strategies[] = new StrategyRemoveForeignElements();
	    	$this->strategies[] = new StrategyMakeWellFormed();
	    	$this->strategies[] = new StrategyFixNesting();
	    	$this->strategies[] = new StrategyValidateAttributes();
    }
}

// vim: et sw=4 sts=4
