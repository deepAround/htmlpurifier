namespace HTMLPurifier\ConfigSchema\Builder;

/**
 * Converts ConfigSchema_Interchange to our runtime
 * representation used to perform checks on user configuration.
 */
use HTMLPurifier\ConfigSchema;
class ConfigSchemaBuilderConfigSchema
{
    /**
     * @param ConfigSchema_Interchange $interchange
     * @return ConfigSchema
     */
    public function build(interchange) -> <ConfigSchema>
    {
        var schema, d, alias;
    
        let schema =  new ConfigSchema();
        for d in interchange->directives {
            schema->add(d->id->key, d->default, d->type, d->typeAllowsNull);
            if d->allowed !== null {
                schema->addAllowedValues(d->id->key, d->allowed);
            }
            for alias in d->aliases {
                schema->addAlias(alias->key, d->id->key);
            }
            if d->valueAliases !== null {
                schema->addValueAliases(d->id->key, d->valueAliases);
            }
        }
        schema->postProcess();
        return schema;
    }

}