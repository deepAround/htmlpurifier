<?php
namespace HTMLPurifier\TagTransform;

use HTMLPurifier\TagTransform;
use HTMLPurifier\Token\TokenEmpty;
use HTMLPurifier\Token\TokenStart;

/**
 * Simple transformation, just change tag name to something else,
 * and possibly add some styling. This will cover most of the deprecated
 * tag cases.
 */
class TagTransformSimple extends TagTransform
{
    /**
     * @type string
     */
    protected $style;

    /**
     * @param string $transform_to Tag name to transform to.
     * @param string $style CSS style to add to the tag
     */
    public function __construct($transform_to, $style = null)
    {
        $this->transform_to = $transform_to;
        $this->style = $style;
    }

    /**
     * @param TokenTag $tag
     * @param Config $config
     * @param Context $context
     * @return string
     */
    public function transform($tag, $config, $context)
    {
        $new_tag = clone $tag;
        $new_tag->name = $this->transform_to;
        if (!is_null($this->style) &&
            ($new_tag instanceof TokenStart || $new_tag instanceof TokenEmpty)
        ) {
            $this->prependCSS($new_tag->attr, $this->style);
        }
        return $new_tag;
    }
}

// vim: et sw=4 sts=4
