namespace HTMLPurifier;


class HTMLPurifier
{
    /**
     * Version of HTML Purifier.
     * @type string
     */
    public version = "4.10.0";
    /**
     * Constant with version of HTML Purifier.
     */
    const VERSION = "4.10.0";
    /**
     * Global configuration object.
     * @type Config
     */
    public config;
    /**
     * Array of extra filter objects to run on HTML,
     * for backwards compatibility.
     * @type Filter[]
     */
    protected filters = [];
    /**
     * Single instance of HTML Purifier.
     * @type HTMLPurifier
     */
    protected static instance;
    /**
     * @type Strategy_Core
     */
    protected strategy;
    /**
     * @type Generator
     */
    protected generator;
    /**
     * Resultant context of last run purification.
     * Is an array of contexts if the last called method was purifyArray().
     * @type Context
     */
    public context;
    /**
     * Initializes the purifier.
     *
     * @param Config|mixed $config Optional Config object
     *                for all instances of the purifier, if omitted, a default
     *                configuration is supplied (which can be overridden on a
     *                per-use basis).
     *                The parameter can also be any type that
     *                Config::create() supports.
     */
    public function __construct(config = null) -> void
    {

    }
    
    /**
     * Adds a filter to process the output. First come first serve
     *
     * @param Filter $filter Filter object
     */
    public function addFilter(<Filter> filter) -> void
    {
        trigger_error("HTMLPurifier->addFilter() is deprecated, use configuration directives" . " in the Filter namespace or Filter.Custom", E_USER_WARNING);
        let this->filters[] = filter;
    }
    
    /**
     * Filters an HTML snippet/document to be XSS-free and standards-compliant.
     *
     * @param string $html String of HTML to purify
     * @param Config $config Config object for this operation,
     *                if omitted, defaults to the config object specified during this
     *                object's construction. The parameter can also be any type
     *                that Config::create() supports.
     *
     * @return string Purified HTML
     */
    public function purify(string html, <Config> config = null)
    {
       
    }
}