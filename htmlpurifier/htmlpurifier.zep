namespace HTMLPurifier;


class HTMLPurifier
{
    
    public version = "4.10.0";
    
    const VERSION = "4.10.0";
    
    public config;
    
    protected filters = [];
    
    protected static instance;
    
    protected strategy;
    
    protected generator;
    
    public context;
    
    public function __construct(config = null) -> void
    {

    }
    
    public function addFilter(var filter) -> void
    {
        let this->filters[] = filter;
    }
    
    public function purify(string html, var config = null)
    {
       
    }
}