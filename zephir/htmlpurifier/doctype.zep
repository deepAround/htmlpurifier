namespace HTMLPurifier;

/**
 * Represents a document type, contains information on which modules
 * need to be loaded.
 * @note This class is inspected by Printer_HTMLDefinition->renderDoctype.
 *       If structure changes, please update that function.
 */
class Doctype
{
    /**
     * Full name of doctype
     * @type string
     */
    public name;
    /**
     * List of standard modules (string identifiers or literal objects)
     * that this doctype uses
     * @type array
     */
    public modules = [];
    /**
     * List of modules to use for tidying up code
     * @type array
     */
    public tidyModules = [];
    /**
     * Is the language derived from XML (i.e. XHTML)?
     * @type bool
     */
    public xml = true;
    /**
     * List of aliases for this doctype
     * @type array
     */
    public aliases = [];
    /**
     * Public DTD identifier
     * @type string
     */
    public dtdPublic;
    /**
     * System DTD identifier
     * @type string
     */
    public dtdSystem;
    public function __construct(name = null, xml = true, modules = [], tidyModules = [], aliases = [], dtd_public = null, dtd_system = null) -> void
    {
        let this->name = name;
        let this->xml = xml;
        let this->modules = modules;
        let this->tidyModules = tidyModules;
        let this->aliases = aliases;
        let this->dtdPublic = dtd_public;
        let this->dtdSystem = dtd_system;
    }

}