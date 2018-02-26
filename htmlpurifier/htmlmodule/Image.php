<?php
namespace HTMLPurifier\HTMLModule;

use HTMLPurifier\HTMLModule;
use HTMLPurifier\AttrDef\AttrDefURI;
use HTMLPurifier\AttrTransform\AttrTransformImgRequired;

/**
 * XHTML 1.1 Image Module provides basic image embedding.
 * @note There is specialized code for removing empty images in
 *       Strategy_RemoveForeignElements
 */
class HTMLModuleImage extends HTMLModule
{

    /**
     * @type string
     */
    public $name = 'Image';

    /**
     * @param Config $config
     */
    public function setup($config)
    {
        $max = $config->get('HTML.MaxImgLength');
        $img = $this->addElement(
            'img',
            'Inline',
            'Empty',
            'Common',
            array(
                'alt*' => 'Text',
                // According to the spec, it's Length, but percents can
                // be abused, so we allow only Pixels.
                'height' => 'Pixels#' . $max,
                'width' => 'Pixels#' . $max,
                'longdesc' => 'URI',
                'src*' => new AttrDefURI(true), // embedded
            )
        );
        if ($max === null || $config->get('HTML.Trusted')) {
            $img->attr['height'] =
            $img->attr['width'] = 'Length';
        }

        // kind of strange, but splitting things up would be inefficient
        $img->attr_transform_pre[] =
        $img->attr_transform_post[] =
            new AttrTransformImgRequired();
    }
}

// vim: et sw=4 sts=4
