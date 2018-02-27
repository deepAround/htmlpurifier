namespace HTMLPurifier\URIFilter;

use HTMLPurifier\URIFilter;
// does not support network paths
class URIFilterMakeAbsolute extends URIFilter
{
    /**
     * @type string
     */
    public name = "MakeAbsolute";
    /**
     * @type
     */
    protected base;
    /**
     * @type array
     */
    protected basePathStack = [];
    /**
     * @param Config $config
     * @return bool
     */
    public function prepare(<Config> config) -> bool
    {
        var def, stack;
    
        let def =  config->getDefinition("URI");
        let this->base =  def->base;
        if is_null(this->base) {
            trigger_error("URI.MakeAbsolute is being ignored due to lack of " . "value for URI.Base configuration", E_USER_WARNING);
            return false;
        }
        let this->base->fragment =  null;
        // fragment is invalid for base URI
        let stack =  explode("/", this->base->path);
        array_pop(stack);
        // discard last segment
        let stack =  this->_collapseStack(stack);
        // do pre-parsing
        let this->basePathStack = stack;
        return true;
    }
    
    /**
     * @param URI $uri
     * @param Config $config
     * @param Context $context
     * @return bool
     */
    public function filter(uri, <Config> config, <Context> context) -> bool
    {
        var scheme_obj, stack, new_stack;
    
        if is_null(this->base) {
            return true;
        }
        // abort early
        if uri->path === "" && is_null(uri->scheme) && is_null(uri->host) && is_null(uri->query) && is_null(uri->fragment) {
            // reference to current document
            let uri =  clone this->base;
            return true;
        }
        if !(is_null(uri->scheme)) {
            // absolute URI already: don't change
            if !(is_null(uri->host)) {
                return true;
            }
            let scheme_obj =  uri->getSchemeObj(config, context);
            if !(scheme_obj) {
                // scheme not recognized
                return false;
            }
            if !(scheme_obj->hierarchical) {
                // non-hierarchal URI with explicit scheme, don't change
                return true;
            }
        }
        if !(is_null(uri->host)) {
            // network path, don't bother
            return true;
        }
        if uri->path === "" {
            let uri->path =  this->base->path;
        } elseif uri->path[0] !== "/" {
            // relative path, needs more complicated processing
            let stack =  explode("/", uri->path);
            let new_stack =  array_merge(this->basePathStack, stack);
            if new_stack[0] !== "" && !(is_null(this->base->host)) {
                array_unshift(new_stack, "");
            }
            let new_stack =  this->_collapseStack(new_stack);
            let uri->path =  implode("/", new_stack);
        } else {
            // absolute path, but still we should collapse
            let uri->path =  implode("/", this->_collapseStack(explode("/", uri->path)));
        }
        // re-combine
        let uri->scheme =  this->base->scheme;
        if is_null(uri->userinfo) {
            let uri->userinfo =  this->base->userinfo;
        }
        if is_null(uri->host) {
            let uri->host =  this->base->host;
        }
        if is_null(uri->port) {
            let uri->port =  this->base->port;
        }
        return true;
    }
    
    /**
     * Resolve dots and double-dots in a path stack
     * @param array $stack
     * @return array
     */
    protected function _collapseStack(array stack) -> array
    {
        var result, is_folder, i, segment;
    
        let result =  [];
        let is_folder =  false;
        
            let i = 0;
        loop {
        if isset stack[i] {
            break;
        }
        
            let is_folder =  false;
            // absorb an internally duplicated slash
            if stack[i] == "" && i && isset stack[i + 1] {
                continue;
            }
            if stack[i] == ".." {
                if !(empty(result)) {
                    let segment =  array_pop(result);
                    if segment === "" && empty(result) {
                        // error case: attempted to back out too far:
                        // restore the leading slash
                        let result[] = "";
                    } elseif segment === ".." {
                        let result[] = "..";
                    }
                } else {
                    // relative path, preserve the double-dots
                    let result[] = "..";
                }
                let is_folder =  true;
                continue;
            }
            if stack[i] == "." {
                // silently absorb
                let is_folder =  true;
                continue;
            }
            let result[] = stack[i];
        
            let i++;
        }
        if is_folder {
            let result[] = "";
        }
        return result;
    }

}