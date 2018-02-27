namespace HTMLPurifier\AttrDef;

/**
 * Validates arbitrary text according to the HTML spec.
 */
class AttrDefText extends \HTMLPurifier\AttrDef
{
    /**
     * @param string $string
     * @param Config $config
     * @param Context $context
     * @return bool|string
     */
    public function validate(string stringg, <Config> config, <Context> context)
    {
        return this->parseCDATA(stringg);
    }

}