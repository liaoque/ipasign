#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import argparse
from isign import isign
from os.path import abspath, expanduser
import logging




FORMATTER = logging.Formatter('%(message)s')


def log_to_stderr(level=logging.INFO):
    root = logging.getLogger()
    root.setLevel(level)
    handler = logging.StreamHandler()
    handler.setFormatter(FORMATTER)
    root.addHandler(handler)


def absolute_path_argument(path):
    return abspath(expanduser(path))


def parse_args():
    # note that for arguments which eventually get fed into
    # isign.resign, we deliberately don't set defaults. The kwarg
    # defaults in isign.resign will be used
    parser = argparse.ArgumentParser(
        description='Resign an iOS application with a new identity '
                    'and provisioning profile. See documentation for '
                    'how to obtain properly formatted credentials.')
    parser.add_argument(
        '-p', '--provisioning-profile',
        dest='provisioning_profile',
        required=False,
        metavar='<your.mobileprovision path>',
        type=absolute_path_argument,
        help='Path to provisioning profile'
    )
    parser.add_argument(
        '-k', '--key',
        dest='key',
        required=False,
        metavar='<key path>',
        type=absolute_path_argument,
        help='Path to your organization\'s key in PEM format.'
    )
    parser.add_argument(
        '-c', '--certificate',
        dest='certificate',
        required=False,
        metavar='<certificate path>',
        type=absolute_path_argument,
        help='Path to your organization\'s certificate in PEM format'
    )
    parser.add_argument(
        '-o', '--output',
        dest='output_path',
        required=False,
        metavar='<output path>',
        type=absolute_path_argument,
        help='Path to output file or directory'
    )
    parser.add_argument(
        '-i', '--info',
        dest='info_props',
        required=False,
        metavar='<Info.plist properties>',
        help='List of comma-delimited key=value pairs of Info.plist properties to override'
    )
    parser.add_argument(
        'app_paths',
        nargs=1,
        metavar='<app path>',
        type=absolute_path_argument,
        help='Path to application to re-sign, typically a '
             'directory ending in .app or file ending in .ipa.'
    )
    parser.add_argument(
        '-e', '--entitlements',
        dest='alternate_entitlements_path',
        required=False,
        metavar='<alternate entitlements path>',
        type=absolute_path_argument,
        help='Sign with these entitlements, rather than ones extracted from provisioning profile'
    )
    return parser.parse_args()


def filter_args(args, interested):
    """ Filter all args to args that we are interested in """
    # We want the unused command line args to be
    # missing in kwargs, so the defaults are used
    kwargs = {}
    for k, v in vars(args).iteritems():
        if k in interested and v is not None:
            kwargs[k] = v
    return kwargs





if __name__ == '__main__':
    defaultencoding = 'utf-8'
    if sys.getdefaultencoding() != defaultencoding:
        reload(sys)
        sys.setdefaultencoding(defaultencoding)
        
    args = parse_args()
    level = logging.INFO
    log_to_stderr(level)

    # Handle the various kinds of resign operations
    kwargs = {}

    # There's only one output path, so it doesn't make sense
    # to have multiple input paths
    app_path = args.app_paths[0]

    # Convert the Info.plist property pairs to a dict format
    if args.info_props:
        info_props = {}
        for arg in args.info_props.split(','):
            i = arg.find('=')
            if i < 0:
                raise Exception('Invalid Info.plist argument: ' + arg)
            info_props[arg[0:i]] = arg[i + 1:]
        if info_props:
            kwargs['info_props'] = info_props


    # Handle standard resign. User may have specified all, some
    # or none of the credential files, in which case we rely on
    # isign.resign() to supply defaults.
    # Massage args into method arguments
    resign_args = ['certificate',
                   'key',
                   'apple_cert',
                   'provisioning_profile',
                   'output_path',
                   'alternate_entitlements_path']
    kwargs.update(filter_args(args, resign_args))
    
    isign.resign(app_path, **kwargs)