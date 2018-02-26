<?php
namespace HTMLPurifier;

use HTMLPurifier\AttrDef\AttrDefClone;
use HTMLPurifier\AttrDef\AttrDefEnum;
use HTMLPurifier\AttrDef\AttrDefInteger;
use HTMLPurifier\AttrDef\AttrDefLang;
use HTMLPurifier\AttrDef\AttrDefText;
use HTMLPurifier\AttrDef\AttrDefURI;
use HTMLPurifier\AttrDef\Html\AttrDefHTMLBool;
use HTMLPurifier\AttrDef\Html\AttrDefHTMLClass;
use HTMLPurifier\AttrDef\Html\AttrDefHTMLColor;
use HTMLPurifier\AttrDef\Html\AttrDefHTMLFrameTarget;
use HTMLPurifier\AttrDef\Html\AttrDefHTMLID;
use HTMLPurifier\AttrDef\Html\AttrDefHTMLLength;
use HTMLPurifier\AttrDef\Html\AttrDefHTMLMultiLength;
use HTMLPurifier\AttrDef\Html\AttrDefHTMLNmtokens;
use HTMLPurifier\AttrDef\Html\AttrDefHTMLPixels;

/**
 * Provides lookup array of attribute types to AttrDef objects
 */
class AttrTypes
{
    /**
     * Lookup array of attribute string identifiers to concrete implementations.
     * @type AttrDef[]
     */
    protected $info = array();

    /**
     * Constructs the info array, supplying default implementations for attribute
     * types.
     */
    public function __construct()
    {
        // XXX This is kind of poor, since we don't actually /clone/
        // instances; instead, we use the supplied make() attribute. So,
        // the underlying class must know how to deal with arguments.
        // With the old implementation of Enum, that ignored its
        // arguments when handling a make dispatch, the IAlign
        // definition wouldn't work.

        // pseudo-types, must be instantiated via shorthand
        $this->info['Enum']    = new AttrDefEnum();
        $this->info['Bool']    = new AttrDefHTMLBool();

        $this->info['CDATA']    = new AttrDefText();
        $this->info['ID']       = new AttrDefHTMLID();
        $this->info['Length']   = new AttrDefHTMLLength();
        $this->info['MultiLength'] = new AttrDefHTMLMultiLength();
        $this->info['NMTOKENS'] = new AttrDefHTMLNmtokens();
        $this->info['Pixels']   = new AttrDefHTMLPixels();
        $this->info['Text']     = new AttrDefText();
        $this->info['URI']      = new AttrDefURI();
        $this->info['LanguageCode'] = new AttrDefLang();
        $this->info['Color']    = new AttrDefHTMLColor();
        $this->info['IAlign']   = self::makeEnum('top,middle,bottom,left,right');
        $this->info['LAlign']   = self::makeEnum('top,bottom,left,right');
        $this->info['FrameTarget'] = new AttrDefHTMLFrameTarget();

        // unimplemented aliases
        $this->info['ContentType'] = new AttrDefText();
        $this->info['ContentTypes'] = new AttrDefText();
        $this->info['Charsets'] = new AttrDefText();
        $this->info['Character'] = new AttrDefText();

        // "proprietary" types
        $this->info['Class'] = new AttrDefHTMLClass();

        // number is really a positive integer (one or more digits)
        // FIXME: ^^ not always, see start and value of list items
        $this->info['Number']   = new AttrDefInteger(false, false, true);
    }

    private static function makeEnum($in)
    {
        return new AttrDefClone(new AttrDefEnum(explode(',', $in)));
    }

    /**
     * Retrieves a type
     * @param string $type String type name
     * @return AttrDef Object AttrDef for type
     */
    public function get($type)
    {
        // determine if there is any extra info tacked on
        if (strpos($type, '#') !== false) {
            list($type, $string) = explode('#', $type, 2);
        } else {
            $string = '';
        }

        if (!isset($this->info[$type])) {
            trigger_error('Cannot retrieve undefined attribute type ' . $type, E_USER_ERROR);
            return;
        }
        return $this->info[$type]->make($string);
    }

    /**
     * Sets a new implementation for a type
     * @param string $type String type name
     * @param AttrDef $impl Object AttrDef for type
     */
    public function set($type, $impl)
    {
        $this->info[$type] = $impl;
    }
}

// vim: et sw=4 sts=4
