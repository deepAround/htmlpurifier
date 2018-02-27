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
    protected strategies = [];
    /**
     * @param Token[] $tokens
     * @param Config $config
     * @param Context $context
     * @return Token[]
     */
    public function execute(array tokens, <Config> config, <Context> context) -> array
    {
        var strategy;
    
        for strategy in this->strategies {
            let tokens =  strategy->execute(tokens, config, context);
        }
        return tokens;
    }

}