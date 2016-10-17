#!/usr/bin/python
# -*- coding: utf-8 -*-

# (c) 2016, David Cook <dcook@prosentient.com.au>

import ConfigParser

def get_site_facts(module):
    setup_options = dict(module_setup=True)
    src = module.params['src']

    setup_result = { 'ansible_facts': { 'site_facts' : {} } }

    Config = ConfigParser.ConfigParser()
    Config.read(src)
    sections = Config.sections()
    for section in sections:
        setup_result['ansible_facts']['site_facts'][section] = {}
        options = Config.options(section)
        for option in options:
            value = Config.get(section, option)
            setup_result['ansible_facts']['site_facts'][section][option] = value
    return setup_result

def main():
    module = AnsibleModule(
        argument_spec = dict(
            src=dict(required=True,),
        ),
        supports_check_mode = True,
    )
    data = get_site_facts(module)
    module.exit_json(**data)

# import module snippets
from ansible.module_utils.basic import *

if __name__ == '__main__':
    main()