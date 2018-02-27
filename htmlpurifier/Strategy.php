<?php
namespace HTMLPurifier;

/**
 * Supertype for classes that define a strategy for modifying/purifying tokens.
 *
 * While HTMLPurifier's core purpose is fixing HTML into something proper,
 * strategies provide plug points for extra configuration or even extra
 * features, such as custom tags, custom parsing of text, etc.
 */


abstract class Strategy
{

    /**
     * Executes the strategy on the tokens.
     *
     * @param Token[] $tokens Array of Token objects to be operated on.
     * @param Config $config
     * @param Context $context
     * @return Token[] Processed array of token objects.
     */
    abstract public function execute($tokens, $config, $context);
}

// vim: et sw=4 sts=4