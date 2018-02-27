namespace HTMLPurifier;

/**
 * Error collection class that enables HTML Purifier to report HTML
 * problems back to the user
 */
class ErrorCollector
{
    /**
     * Identifiers for the returned error array. These are purposely numeric
     * so list() can be used.
     */
    const LINENO = 0;
    const SEVERITY = 1;
    const MESSAGE = 2;
    const CHILDREN = 3;
    /**
     * @type array
     */
    protected errors;
    /**
     * @type array
     */
    protected _current;
    /**
     * @type array
     */
    protected _stacks = [[]];
    /**
     * @type Language
     */
    protected locale;
    /**
     * @type Generator
     */
    protected generator;
    /**
     * @type Context
     */
    protected context;
    /**
     * @type array
     */
    protected lines = [];
    /**
     * @param Context $context
     */
    public function __construct(<Context> context) -> void
    {
        let this->locale = context->get("Locale");
        let this->context = context;
        let this->_current = this->_stacks[0];
        let this->errors = this->_stacks[0];
    }
    
    /**
     * Sends an error message to the collector for later use
     * @param int $severity Error severity, PHP error style (don't use E_USER_)
     * @param string $msg Error message text
     */
    public function send(int severity, string msg) -> void
    {
        var args, token, line, col, attr, subst, error, new_struct, struct, tmp1, tmp2, tmp3;
    
        let args =  [];
        if func_num_args() > 2 {
            let args =  func_get_args();
            array_shift(args);
            unset args[0];
        
        }
        let token =  this->context->get("CurrentToken", true);
        let line =  token ? token->line  : this->context->get("CurrentLine", true);
        let col =  token ? token->col  : this->context->get("CurrentCol", true);
        let attr =  this->context->get("CurrentAttr", true);
        // perform special substitutions, also add custom parameters
        let subst =  [];
        if !(is_null(token)) {
            let args["CurrentToken"] = token;
        }
        if !(is_null(attr)) {
            let subst["$CurrentAttr.Name"] = attr;
            if isset token->attr[attr] {
                let subst["$CurrentAttr.Value"] = token->attr[attr];
            }
        }
        if empty(args) {
            let msg =  this->locale->getMessage(msg);
        } else {
            let msg =  this->locale->formatMessage(msg, args);
        }
        if !(empty(subst)) {
            let msg =  strtr(msg, subst);
        }
        // (numerically indexed)
        let error =  [self::LINENO : line, self::SEVERITY : severity, self::MESSAGE : msg, self::CHILDREN : []];
        let this->_current[] = error;
        // NEW CODE BELOW ...
        // Top-level errors are either:
        //  TOKEN type, if $value is set appropriately, or
        //  "syntax" type, if $value is null
        let new_struct =  new ErrorStruct();
        let new_struct->type =  ErrorStruct::TOKEN;
        if token {
            let new_struct->value =  clone token;
        }
        if is_int(line) && is_int(col) {
            if isset this->lines[line][col] {
                let struct = this->lines[line][col];
            } else {
                let struct = new_struct;
                let this->lines[line][col] = new_struct;
                ;
            }
            // These ksorts may present a performance problem
            ksort(this->lines[line], SORT_NUMERIC);
        } else {
            if isset 
            -1;
            let tmp1 = ;
            
            this->lines[tmp1] {
                
                -1;
                let tmp2 = ;
                
                let struct = this->lines[tmp2];
            } else {
                let struct = new_struct;
                let 
                -1;
                let tmp3 = ;
                
                this->lines[tmp3] = new_struct;
                ;
            }
        }
        ksort(this->lines, SORT_NUMERIC);
        // Now, check if we need to operate on a lower structure
        if !(empty(attr)) {
            let struct =  struct->getChild(ErrorStruct::ATTR, attr);
            if !(struct->value) {
                let struct->value =  [attr, "PUT VALUE HERE"];
            }
        }
        if !(empty(cssprop)) {
            let struct =  struct->getChild(ErrorStruct::CSSPROP, cssprop);
            if !(struct->value) {
                // if we tokenize CSS this might be a little more difficult to do
                let struct->value =  [cssprop, "PUT VALUE HERE"];
            }
        }
        // Ok, structs are all setup, now time to register the error
        struct->addError(severity, msg);
    }
    
    /**
     * Retrieves raw error data for custom formatter to use
     */
    public function getRaw()
    {
        return this->errors;
    }
    
    /**
     * Default HTML formatting implementation for error messages
     * @param Config $config Configuration, vital for HTML output nature
     * @param array $errors Errors array to display; used for recursion.
     * @return string
     */
    public function getHTMLFormatted(<Config> config, array errors = null) -> string
    {
        var ret, line, col_array, col, struct, tmp1, tmp2;
    
        let ret =  [];
        let this->generator =  new Generator(config, this->context);
        if errors === null {
            let errors =  this->errors;
        }
        // 'At line' message needs to be removed
        // generation code for new structure goes here. It needs to be recursive.
        for line, col_array in this->lines {
            if line == -1 {
                continue;
            }
            for col, struct in col_array {
                this->_renderStruct(ret, struct, line, col);
            }
        }
        if isset 
        -1;
        let tmp1 = ;
        
        this->lines[tmp1] {
            this->_renderStruct(ret, 
            -1;
            let tmp2 = ;
            
            this->lines[tmp2]);
        }
        if empty(errors) {
            return "<p>" . this->locale->getMessage("ErrorCollector: No errors") . "</p>";
        } else {
            return "<ul><li>" . implode("</li><li>", ret) . "</li></ul>";
        }
    }
    
    protected function _renderStruct(ret, struct, line = null, col = null) -> void
    {
        var stack, context_stack, current, context, error, severity, msg, tmpListSeverityMsg, stringg, myArray, i;
    
        let stack =  [struct];
        let context_stack =  [[]];
        let current =  array_pop(stack);
        while (current) {
            let context =  array_pop(context_stack);
            for error in current->errors {
                let tmpListSeverityMsg = error;
                let severity = tmpListSeverityMsg[0];
                let msg = tmpListSeverityMsg[1];
                let stringg = "";
                let stringg .= "<div>";
                // W3C uses an icon to indicate the severity of the error.
                let error =  this->locale->getErrorName(severity);
                let stringg .= "<span class=\"error e{severity}\"><strong>{error}</strong></span> ";
                if !(is_null(line)) && !(is_null(col)) {
                    let stringg .= "<em class=\"location\">Line {line}, Column {col}: </em> ";
                } else {
                    let stringg .= "<em class=\"location\">End of Document: </em> ";
                }
                let stringg .= "<strong class=\"description\">" . this->generator->escape(msg) . "</strong> ";
                let stringg .= "</div>";
                // Here, have a marker for the character on the column appropriate.
                // Be sure to clip extremely long lines.
                //$string .= '<pre>';
                //$string .= '';
                //$string .= '</pre>';
                let ret[] = stringg;
            }
            for myArray in current->children {
                let context[] = current;
                let stack =  array_merge(stack, array_reverse(myArray, true));
                let i =  count(myArray);
                for i in range(count(myArray), 0) {
                    let context_stack[] = context;
                }
            }
        let current =  array_pop(stack);
        }
    }

}