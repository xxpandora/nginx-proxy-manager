const Backbone = require('backbone');

const model = Backbone.Model.extend({
    idAttribute: 'id',

    defaults: function () {
        return {
            id:                      undefined,
            created_on:              null,
            modified_on:             null,
            domain_names:            [],
            forward_scheme:          'http',
            forward_host:            '',
            forward_port:            '80',
            access_list_id:          0,
            certificate_id:          0,
            ssl_forced:              false,
            hsts_enabled:            false,
            hsts_subdomains:         false,
            caching_enabled:         false,
            allow_websocket_upgrade: false,
            under_attack:            false,
            rate_limit_advanced:     false,
            rate_limit_basic:        false,
            managed_waf:             false,
            http2_support:           false,
            enabled:                 true,
            meta:                    {},
            // The following are expansions:
            owner:                   null,
            access_list:             null,
            certificate:             null
        };
    }
});

module.exports = {
    Model:      model,
    Collection: Backbone.Collection.extend({
        model: model
    })
};
