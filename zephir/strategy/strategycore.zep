namespace HTMLPurifier\Strategy;

/**
 * Core strategy composed of the big four strategies.
 */
class StrategyCore extends StrategyComposite
{
    public function __construct() -> void
    {
        let this->strategies[] = new StrategyRemoveForeignElements();
        let this->strategies[] = new StrategyMakeWellFormed();
        let this->strategies[] = new StrategyFixNesting();
        let this->strategies[] = new StrategyValidateAttributes();
    }

}