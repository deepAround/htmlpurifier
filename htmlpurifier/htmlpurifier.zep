namespace HTMLPurifier;

use HTMLPurifier\Strategy\StrategyCore;
/*! @mainpage
 *
 * HTML Purifier is an HTML filter that will take an arbitrary snippet of
 * HTML and rigorously test, validate and filter it into a version that
 * is safe for output onto webpages. It achieves this by:
 *
 *  -# Lexing (parsing into tokens) the document,
 *  -# Executing various strategies on the tokens:
 *      -# Removing all elements not in the whitelist,
 *      -# Making the tokens well-formed,
 *      -# Fixing the nesting of the nodes, and
 *      -# Validating attributes of the nodes; and
 *  -# Generating HTML from the purified tokens.
 *
 * However, most users will only need to interface with the HTMLPurifier
 * and Config.
 */
/*
   HTML Purifier 4.10.0 - Standards Compliant HTML Filtering
   Copyright (C) 2006-2008 Edward Z. Yang

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/
/**
 * Facade that coordinates HTML Purifier's subsystems in order to purify HTML.
 *
 * @note There are several points in which configuration can be specified
 *       for HTML Purifier.  The precedence of these (from lowest to
 *       highest) is as follows:
 *          -# Instance: new HTMLPurifier($config)
 *          -# Invocation: purify($html, $config)
 *       These configurations are entirely independent of each other and
 *       are *not* merged (this behavior may change in the future).
 *
 * @todo We need an easier way to inject strategies using the configuration
 *       object.
 */
class HTMLPurifier
{
    /**
     * Version of HTML Purifier.
     * @type string
     */
    public version = "4.10.0";
    /**
     * Constant with version of HTML Purifier.
     */
    const VERSION = "4.10.0";
    /**
     * Global configuration object.
     * @type Config
     */
    public config;
    /**
     * Array of extra filter objects to run on HTML,
     * for backwards compatibility.
     * @type Filter[]
     */
    protected filters = [];
    /**
     * Single instance of HTML Purifier.
     * @type HTMLPurifier
     */
    protected static instance;
    /**
     * @type Strategy_Core
     */
    protected strategy;
    /**
     * @type Generator
     */
    protected generator;
    /**
     * Resultant context of last run purification.
     * Is an array of contexts if the last called method was purifyArray().
     * @type Context
     */
    public context;
    /**
     * Initializes the purifier.
     *
     * @param Config|mixed $config Optional Config object
     *                for all instances of the purifier, if omitted, a default
     *                configuration is supplied (which can be overridden on a
     *                per-use basis).
     *                The parameter can also be any type that
     *                Config::create() supports.
     */
    public function __construct(config = null) -> void
    {
        let this->config =  Config::create(config);
        let this->strategy =  new StrategyCore();
    }
    
    /**
     * Adds a filter to process the output. First come first serve
     *
     * @param Filter $filter Filter object
     */
    public function addFilter(<Filter> filter) -> void
    {
        trigger_error("HTMLPurifier->addFilter() is deprecated, use configuration directives" . " in the Filter namespace or Filter.Custom", E_USER_WARNING);
        let this->filters[] = filter;
    }
    
    /**
     * Filters an HTML snippet/document to be XSS-free and standards-compliant.
     *
     * @param string $html String of HTML to purify
     * @param Config $config Config object for this operation,
     *                if omitted, defaults to the config object specified during this
     *                object's construction. The parameter can also be any type
     *                that Config::create() supports.
     *
     * @return string Purified HTML
     */
    public function purify(string html, <Config> config = null) -> string
    {
        var lexer, context, language_factory, language, error_collector, id_accumulator, filter_flags, custom_filters, filters, filter, flag, classs, i, filter_size;
    
        // :TODO: make the config merge in, instead of replace
        let config =  config ? Config::create(config)  : this->config;
        // implementation is partially environment dependant, partially
        // configuration dependant
        let lexer =  Lexer::create(config);
        let context =  new Context();
        // setup HTML generator
        let this->generator =  new Generator(config, context);
        context->register("Generator", this->generator);
        // set up global context variables
        if config->get("Core.CollectErrors") {
            // may get moved out if other facilities use it
            let language_factory =  LanguageFactory::instance();
            let language =  language_factory->create(config, context);
            context->register("Locale", language);
            let error_collector =  new ErrorCollector(context);
            context->register("ErrorCollector", error_collector);
        }
        // setup id_accumulator context, necessary due to the fact that
        // AttrValidator can be called from many places
        let id_accumulator =  IDAccumulator::build(config, context);
        context->register("IDAccumulator", id_accumulator);
        let html =  Encoder::convertToUTF8(html, config, context);
        // setup filters
        let filter_flags =  config->getBatch("Filter");
        let custom_filters = filter_flags["Custom"];
        unset filter_flags["Custom"];
        
        let filters =  [];
        for filter, flag in filter_flags {
            if !(flag) {
                continue;
            }
            if strpos(filter, ".") !== false {
                continue;
            }
            let classs = "Filter_{filter}";
            let filters[] = new {classs}();
        }
        for filter in custom_filters {
            // maybe "Filter_$filter", but be consistent with AutoFormat
            let filters[] = filter;
        }
        let filters =  array_merge(filters, this->filters);
        // maybe prepare(), but later
        let i = 0;
        let filter_size =  count(filters);
        for i in range(0, filter_size) {
            let html =  filters[i]->preFilter(html, config, context);
        }
        // purified HTML
        let html =  this->generator->generateFromTokens(this->strategy->execute(lexer->tokenizeHTML(html, config, context), config, context));
        let i =  filter_size - 1;
        for i in range(filter_size - 1, 0) {
            let html =  filters[i]->postFilter(html, config, context);
        }
        let html =  Encoder::convertFromUTF8(html, config, context);
        let this->context = context;
        return html;
    }
    
    /**
     * Filters an array of HTML snippets
     *
     * @param string[] $array_of_html Array of html snippets
     * @param Config $config Optional config object for this operation.
     *                See HTMLPurifier::purify() for more details.
     *
     * @return string[] Array of purified HTML
     */
    public function purifyArray(array array_of_html, <Config> config = null) -> array
    {
        var context_array, key, html;
    
        let context_array =  [];
        for key, html in array_of_html {
            let array_of_html[key] =  this->purify(html, config);
            let context_array[key] = this->context;
        }
        let this->context = context_array;
        return array_of_html;
    }
    
    /**
     * Singleton for enforcing just one HTML Purifier in your system
     *
     * @param HTMLPurifier|Config $prototype Optional prototype
     *                   HTMLPurifier instance to overload singleton with,
     *                   or Config instance to configure the
     *                   generated version with.
     *
     * @return HTMLPurifier
     */
    public static function instance(prototype = null) -> <HTMLPurifier>
    {
        if !(self::instance) || prototype {
            if prototype instanceof HTMLPurifier {
                let self::instance = prototype;
            } elseif prototype {
                let self::instance =  new HTMLPurifier(prototype);
            } else {
                let self::instance =  new HTMLPurifier();
            }
        }
        return self::instance;
    }
    
    /**
     * Singleton for enforcing just one HTML Purifier in your system
     *
     * @param HTMLPurifier|Config $prototype Optional prototype
     *                   HTMLPurifier instance to overload singleton with,
     *                   or Config instance to configure the
     *                   generated version with.
     *
     * @return HTMLPurifier
     * @note Backwards compatibility, see instance()
     */
    public static function getInstance(prototype = null) -> <HTMLPurifier>
    {
        return HTMLPurifier::instance(prototype);
    }

}