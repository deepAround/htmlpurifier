<?php
namespace HTMLPurifier\AttrTransform;

// this MUST be placed in post, as it assumes that any value in dir is valid

/**
 * Post-trasnform that ensures that bdo tags have the dir attribute set.
 */
class AttrTransformBdoDir extends \HTMLPurifier\AttrTransform
{

    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform($attr, $config, $context)
    {
        if (isset($attr['dir'])) {
            return $attr;
        }
        $attr['dir'] = $config->get('Attr.DefaultTextDir');
        return $attr;
    }
}

// vim: et sw=4 sts=4