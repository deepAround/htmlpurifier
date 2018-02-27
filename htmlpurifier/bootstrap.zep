namespace HTMLPurifier;

use ReflectionMethod;
// constants are slow, so we use as few as possible
if !(defined("PREFIX")) {
    define("PREFIX", realpath(dirname(__FILE__) . "/.."));
}
// accomodations for versions earlier than 5.0.2
// borrowed from PHP_Compat, LGPL licensed, by Aidan Lister <aidan@php.net>
if !(defined("PHP_EOL")) {
    switch (strtoupper(substr(PHP_OS, 0, 3))) {
        case "WIN":
            define("PHP_EOL", "
");
            break;
        case "DAR":
            define("PHP_EOL", "");
            break;
        default:
            define("PHP_EOL", "
");
    }
}
/**
 * Bootstrap class that contains meta-functionality for HTML Purifier such as
 * the autoload function.
 *
 * @note
 *      This class may be used without any other files from HTML Purifier.
 */
class Bootstrap
{
    /**
     * Autoload function for HTML Purifier
     * @param string $class Class to load
     * @return bool
     */
    public static function autoload(string classs) -> bool
    {
        var file;
    
        let file =  Bootstrap::getPath(classs);
        if !(file) {
            return false;
        }
        // Technically speaking, it should be ok and more efficient to
        // just do 'require', but Antonio Parraga reports that with
        // Zend extensions such as Zend debugger and APC, this invariant
        // may be broken.  Since we have efficient alternatives, pay
        // the cost here and avoid the bug.
        require_once PREFIX . "/" . file;
        return true;
    }
    
    /**
     * Returns the path for a specific class.
     * @param string $class Class path to get
     * @return string
     */
    public static function getPath(string classs) -> string
    {
        var code, file;
    
        if strncmp("HTMLPurifier", classs, 12) !== 0 {
            return false;
        }
        // Custom implementations
        if strncmp("Language_", classs, 22) === 0 {
            let code =  str_replace("_", "-", substr(classs, 22));
            let file =  "HTMLPurifier/Language/classes/" . code . ".php";
        } else {
            let file =  str_replace("_", "/", classs) . ".php";
        }
        if !(file_exists(PREFIX . "/" . file)) {
            return false;
        }
        return file;
    }
    
    /**
     * "Pre-registers" our autoloader on the SPL stack.
     */
    public static function registerAutoload() -> void
    {
        var autoload, funcs, buggy, compat, func, reflector;
    
        let autoload =  ["Bootstrap", "autoload"];
        let funcs =  spl_autoload_functions();
        if funcs === false {
            spl_autoload_register(autoload);
        } elseif function_exists("spl_autoload_unregister") {
            if version_compare(PHP_VERSION, "5.3.0", ">=") {
                // prepend flag exists, no need for shenanigans
                spl_autoload_register(autoload, true, true);
            } else {
                let buggy =  version_compare(PHP_VERSION, "5.2.11", "<");
                let compat =  version_compare(PHP_VERSION, "5.1.2", "<=") && version_compare(PHP_VERSION, "5.1.0", ">=");
                for func in funcs {
                    if buggy && is_array(func) {
                        // :TRICKY: There are some compatibility issues and some
                        // places where we need to error out
                        let reflector =  new ReflectionMethod(func[0], func[1]);
                        if !(reflector->isStatic()) {
                            throw new Exception("HTML Purifier autoloader registrar is not compatible
                                with non-static object methods due to PHP Bug #44144;
                                Please do not use HTMLPurifier.autoload.php (or any
                                file that includes this file); instead, place the code:
                                spl_autoload_register(array('Bootstrap', 'autoload'))
                                after your own autoloaders.");
                        }
                        // Suprisingly, spl_autoload_register supports the
                        // Class::staticMethod callback format, although call_user_func doesn't
                        if compat {
                            let func =  implode("::", func);
                        }
                    }
                    spl_autoload_unregister(func);
                }
                spl_autoload_register(autoload);
                for func in funcs {
                    spl_autoload_register(func);
                }
            }
        }
    }

}