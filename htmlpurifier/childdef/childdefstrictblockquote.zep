namespace HTMLPurifier\ChildDef;

use HTMLPurifier\Node\NodeElement;
use HTMLPurifier\Node\NodeText;
/**
 * Takes the contents of blockquote when in strict and reformats for validation.
 */
class ChildDefStrictBlockquote extends ChildDefRequired
{
    /**
     * @type array
     */
    protected real_elements;
    /**
     * @type array
     */
    protected fake_elements;
    /**
     * @type bool
     */
    public allow_empty = true;
    /**
     * @type string
     */
    public type = "strictblockquote";
    /**
     * @type bool
     */
    protected init = false;
    /**
     * @param Config $config
     * @return array
     * @note We don't want MakeWellFormed to auto-close inline elements since
     *       they might be allowed.
     */
    public function getAllowedElements(<Config> config) -> array
    {
        this->init(config);
        return this->fake_elements;
    }
    
    /**
     * @param array $children
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function validateChildren(array children, <Config> config, <Context> context) -> array
    {
        var result, tmpArray40cd750bba9870f18aada2478b24840a, def, block_wrap_name, block_wrap, ret, node;
    
        this->init(config);
        // trick the parent class into thinking it allows more
        let this->elements =  this->fake_elements;
        let result =  parent::validateChildren(children, config, context);
        let this->elements =  this->real_elements;
        if result === false {
            let tmpArray40cd750bba9870f18aada2478b24840a = [];
            return tmpArray40cd750bba9870f18aada2478b24840a;
        }
        if result === true {
            let result = children;
        }
        let def =  config->getHTMLDefinition();
        let block_wrap_name =  def->info_block_wrapper;
        let block_wrap =  false;
        let ret =  [];
        for node in result {
            if block_wrap === false {
                if node instanceof NodeText && !(node->is_whitespace) || node instanceof NodeElement && !(isset this->elements[node->name]) {
                    let block_wrap =  new NodeElement(def->info_block_wrapper);
                    let ret[] = block_wrap;
                }
            } else {
                if node instanceof NodeElement && isset this->elements[node->name] {
                    let block_wrap =  false;
                }
            }
            if block_wrap {
                let block_wrap->children[] = node;
            } else {
                let ret[] = node;
            }
        }
        return ret;
    }
    
    /**
     * @param Config $config
     */
    protected function init(<Config> config) -> void
    {
        var def;
    
        if !(this->init) {
            let def =  config->getHTMLDefinition();
            // allow all inline elements
            let this->real_elements =  this->elements;
            let this->fake_elements = def->info_content_sets["Flow"];
            let this->fake_elements["#PCDATA"] = true;
            let this->init =  true;
        }
    }

}