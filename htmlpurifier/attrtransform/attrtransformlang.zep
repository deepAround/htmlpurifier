namespace HTMLPurifier\AttrTransform;

/**
 * Post-transform that copies lang's value to xml:lang (and vice-versa)
 * @note Theoretically speaking, this could be a pre-transform, but putting
 *       post is more efficient.
 */
class AttrTransformLang extends \HTMLPurifier\AttrTransform
{
    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform(array attr, <Config> config, <Context> context) -> array
    {
        var lang, xml_lang;
    
        let lang =  isset attr["lang"] ? attr["lang"]  : false;
        let xml_lang =  isset attr["xml:lang"] ? attr["xml:lang"]  : false;
        if lang !== false && xml_lang === false {
            let attr["xml:lang"] = lang;
        } elseif xml_lang !== false {
            let attr["lang"] = xml_lang;
        }
        return attr;
    }

}