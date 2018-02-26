<?php

namespace HTMLPurifier\AttrTransform;

use HTMLPurifier\URIParser;

// must be called POST validation

/**
 * Adds target="blank" to all outbound links.  This transform is
 * only attached if Attr.TargetBlank is TRUE.  This works regardless
 * of whether or not Attr.AllowedFrameTargets
 */
class AttrTransformTargetBlank extends \HTMLPurifier\AttrTransform
{
    /**
     * @type URIParser
     */
    private $parser;

    public function __construct()
    {
        $this->parser = new URIParser();
    }

    /**
     * @param array $attr
     * @param Config $config
     * @param Context $context
     * @return array
     */
    public function transform($attr, $config, $context)
    {
        if (!isset($attr['href'])) {
            return $attr;
        }

        // XXX Kind of inefficient
        $url = $this->parser->parse($attr['href']);
        $scheme = $url->getSchemeObj($config, $context);

        if ($scheme->browsable && !$url->isBenign($config, $context)) {
            $attr['target'] = '_blank';
        }
        return $attr;
    }
}

// vim: et sw=4 sts=4
