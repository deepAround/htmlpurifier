<?php
namespace HTMLPurifier\Strategy;

/**
 * Composite strategy that runs multiple strategies on tokens.
 */
abstract class StrategyComposite extends \HTMLPurifier\Strategy
{

    /**
     * List of strategies to run tokens through.
     * @type Strategy[]
     */
    protected $strategies = array();

    /**
     * @param Token[] $tokens
     * @param Config $config
     * @param Context $context
     * @return Token[]
     */
    public function execute($tokens, $config, $context)
    {
        foreach ($this->strategies as $strategy) {
            $tokens = $strategy->execute($tokens, $config, $context);
        }
        return $tokens;
    }
}

// vim: et sw=4 sts=4
