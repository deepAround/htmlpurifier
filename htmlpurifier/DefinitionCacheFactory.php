<?php
namespace HTMLPurifier;

use HTMLPurifier\DefinitionCache\DefinitionCacheNull;
use HTMLPurifier\DefinitionCache\DefinitionCacheSerializer;

/**
 * Responsible for creating definition caches.
 */
class DefinitionCacheFactory
{
    /**
     * @type array
     */
    protected $caches = array('Serializer' => array());

    /**
     * @type array
     */
    protected $implementations = array();

    /**
     * @type DefinitionCacheDecorator[]
     */
    protected $decorators = array();

    /**
     * Initialize default decorators
     */
    public function setup()
    {
        $this->addDecorator('Cleanup');
    }

    /**
     * Retrieves an instance of global definition cache factory.
     * @param DefinitionCacheFactory $prototype
     * @return DefinitionCacheFactory
     */
    public static function instance($prototype = null)
    {
        static $instance;
        if ($prototype !== null) {
            $instance = $prototype;
        } elseif ($instance === null || $prototype === true) {
            $instance = new DefinitionCacheFactory();
            $instance->setup();
        }
        return $instance;
    }

    /**
     * Registers a new definition cache object
     * @param string $short Short name of cache object, for reference
     * @param string $long Full class name of cache object, for construction
     */
    public function register($short, $long)
    {
        $this->implementations[$short] = $long;
    }

    /**
     * Factory method that creates a cache object based on configuration
     * @param string $type Name of definitions handled by cache
     * @param Config $config Config instance
     * @return mixed
     */
    public function create($type, $config)
    {
        $method = $config->get('Cache.DefinitionImpl');
        if ($method === null) {
            return new DefinitionCacheNull($type);
        }
        if (!empty($this->caches[$method][$type])) {
            return $this->caches[$method][$type];
        }
        if (isset($this->implementations[$method]) &&
            class_exists($class = $this->implementations[$method], false)) {
            $cache = new $class($type);
        } else {
            if ($method != 'Serializer') {
                trigger_error("Unrecognized DefinitionCache $method, using Serializer instead", E_USER_WARNING);
            }
            $cache = new DefinitionCacheSerializer($type);
        }
        foreach ($this->decorators as $decorator) {
            $new_cache = $decorator->decorate($cache);
            // prevent infinite recursion in PHP 4
            unset($cache);
            $cache = $new_cache;
        }
        $this->caches[$method][$type] = $cache;
        return $this->caches[$method][$type];
    }

    /**
     * Registers a decorator to add to all new cache objects
     * @param DefinitionCacheDecorator|string $decorator An instance or the name of a decorator
     */
    public function addDecorator($decorator)
    {
        if (is_string($decorator)) {
            $class = "DefinitionCacheDecorator_$decorator";
            $decorator = new $class;
        }
        $this->decorators[$decorator->name] = $decorator;
    }
}

// vim: et sw=4 sts=4