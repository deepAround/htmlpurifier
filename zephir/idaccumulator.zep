namespace HTMLPurifier;

/**
 * Component of AttrContext that accumulates IDs to prevent dupes
 * @note In Slashdot-speak, dupe means duplicate.
 * @note The default constructor does not accept $config or $context objects:
 *       use must use the static build() factory method to perform initialization.
 */
class IDAccumulator
{
    /**
     * Lookup table of IDs we've accumulated.
     * @public
     */
    public ids = [];
    /**
     * Builds an IDAccumulator, also initializing the default blacklist
     * @param Config $config Instance of Config
     * @param Context $context Instance of Context
     * @return IDAccumulator Fully initialized IDAccumulator
     */
    public static function build(<Config> config, <Context> context) -> <IDAccumulator>
    {
        var id_accumulator;
    
        let id_accumulator =  new IDAccumulator();
        id_accumulator->load(config->get("Attr.IDBlacklist"));
        return id_accumulator;
    }
    
    /**
     * Add an ID to the lookup table.
     * @param string $id ID to be added.
     * @return bool status, true if success, false if there's a dupe
     */
    public function add(string id) -> bool
    {
        if isset this->ids[id] {
            return false;
        }
        let this->ids[id] = true;
        return this->ids[id];
    }
    
    /**
     * Load a list of IDs into the lookup table
     * @param $array_of_ids Array of IDs to load
     * @note This function doesn't care about duplicates
     */
    public function load(array_of_ids) -> void
    {
        var id;
    
        for id in array_of_ids {
            let this->ids[id] = true;
        }
    }

}