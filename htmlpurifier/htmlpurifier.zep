namespace HTMLPurifier;


class HTMLPurifier
{
    
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
        
    }
    
    public function purify(string html, var config = null)
    {
       
    }
}