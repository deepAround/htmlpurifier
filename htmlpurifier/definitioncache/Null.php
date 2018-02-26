<?php
namespace HTMLPurifier\DefinitionCache;

/**
 * Null cache object to use when no caching is on.
 */
use HTMLPurifier\DefinitionCache;

class DefinitionCacheNull extends DefinitionCache
{

    /**
     * @param Definition $def
     * @param Config $config
     * @return bool
     */
    public function add($def, $config)
    {
        return false;
    }

    /**
     * @param Definition $def
     * @param Config $config
     * @return bool
     */
    public function set($def, $config)
    {
        return false;
    }

    /**
     * @param Definition $def
     * @param Config $config
     * @return bool
     */
    public function replace($def, $config)
    {
        return false;
    }

    /**
     * @param Config $config
     * @return bool
     */
    public function remove($config)
    {
        return false;
    }

    /**
     * @param Config $config
     * @return bool
     */
    public function get($config)
    {
        return false;
    }

    /**
     * @param Config $config
     * @return bool
     */
    public function flush($config)
    {
        return false;
    }

    /**
     * @param Config $config
     * @return bool
     */
    public function cleanup($config)
    {
        return false;
    }
}

// vim: et sw=4 sts=4
