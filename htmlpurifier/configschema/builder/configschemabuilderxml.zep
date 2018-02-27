namespace HTMLPurifier\ConfigSchema\Builder;

use HTMLPurifier\HTMLPurifier;
use XMLWriter;
/**
 * Converts ConfigSchema_Interchange to an XML format,
 * which can be further processed to generate documentation.
 */
class ConfigSchemaBuilderXml extends XMLWriter
{
    /**
     * @type ConfigSchema_Interchange
     */
    protected interchange;
    /**
     * @type string
     */
    protected namespacee;
    /**
     * @param string $html
     */
    protected function writeHTMLDiv(string html) -> void
    {
        var purifier;
    
        this->startElement("div");
        let purifier =  HTMLPurifier::getInstance();
        let html =  purifier->purify(html);
        this->writeAttribute("xmlns", "http://www.w3.org/1999/xhtml");
        this->writeRaw(html);
        this->endElement();
    }
    
    /**
     * @param mixed $var
     * @return string
     */
    protected function export(varr) -> string
    {
        var tmpArray40cd750bba9870f18aada2478b24840a;
    
        let tmpArray40cd750bba9870f18aada2478b24840a = [];
        if varr === tmpArray40cd750bba9870f18aada2478b24840a {
            return "array()";
        }
        return var_export(varr, true);
    }
    
    /**
     * @param ConfigSchema_Interchange $interchange
     */
    public function build(interchange) -> void
    {
        var directive;
    
        // global access, only use as last resort
        let this->interchange = interchange;
        this->setIndent(true);
        this->startDocument("1.0", "UTF-8");
        this->startElement("configdoc");
        this->writeElement("title", interchange->name);
        for directive in interchange->directives {
            this->buildDirective(directive);
        }
        if this->namespacee {
            this->endElement();
        }
        // namespace
        this->endElement();
        // configdoc
        this->flush();
    }
    
    /**
     * @param ConfigSchema_Interchange_Directive $directive
     */
    public function buildDirective(directive) -> void
    {
        var alias, value, x, project;
    
        // Kludge, although I suppose having a notion of a "root namespace"
        // certainly makes things look nicer when documentation is built.
        // Depends on things being sorted.
        if !(this->namespacee) || this->namespacee !== directive->id->getRootNamespace() {
            if this->namespacee {
                this->endElement();
            }
            // namespace
            let this->namespacee =  directive->id->getRootNamespace();
            this->startElement("namespace");
            this->writeAttribute("id", this->namespacee);
            this->writeElement("name", this->namespacee);
        }
        this->startElement("directive");
        this->writeAttribute("id", directive->id->toString());
        this->writeElement("name", directive->id->getDirective());
        this->startElement("aliases");
        for alias in directive->aliases {
            this->writeElement("alias", alias->toString());
        }
        this->endElement();
        // aliases
        this->startElement("constraints");
        if directive->version {
            this->writeElement("version", directive->version);
        }
        this->startElement("type");
        if directive->typeAllowsNull {
            this->writeAttribute("allow-null", "yes");
        }
        this->text(directive->type);
        this->endElement();
        // type
        if directive->allowed {
            this->startElement("allowed");
            for value, x in directive->allowed {
                this->writeElement("value", value);
            }
            this->endElement();
        }
        this->writeElement("default", this->export(directive->default));
        this->writeAttribute("xml:space", "preserve");
        if directive->external {
            this->startElement("external");
            for project in directive->external {
                this->writeElement("project", project);
            }
            this->endElement();
        }
        this->endElement();
        // constraints
        if directive->deprecatedVersion {
            this->startElement("deprecated");
            this->writeElement("version", directive->deprecatedVersion);
            this->writeElement("use", directive->deprecatedUse->toString());
            this->endElement();
        }
        this->startElement("description");
        this->writeHTMLDiv(directive->description);
        this->endElement();
        // description
        this->endElement();
    }

}