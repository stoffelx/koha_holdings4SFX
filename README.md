# getHolding implementation of koha catalogues to SFx
You may be interested to implement a getHolding service of a local library to your SFX menu. The current solution candidate offers a plugin-dependent target, i.e. the availability of eligible items is checked in the first place to ensure the target representing local library holdings won't lead to empty result lists. The plugin is used as a conditional by setting an according threshold within the target's details, e.g. $obj->plugIn('KOHA_PLUGIN') here. Furthermore base URLs for local use should be adapted respectively as a getHolding service parse parameter.<br>This draft is still in development and may be subject to further improvements.