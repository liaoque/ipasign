#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import argparse
from isign import isign
from os.path import abspath, expanduser
import logging
import json

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
        'app_paths',
        nargs=1,
        metavar='<app path>',
        type=absolute_path_argument,
        help='Path to application to re-sign, typically a '
             'directory ending in .app or file ending in .ipa.'
    )
    return parser.parse_args()



if __name__ == '__main__':
    defaultencoding = 'utf-8'
    if sys.getdefaultencoding() != defaultencoding:
        reload(sys)
        sys.setdefaultencoding(defaultencoding)
    args = parse_args()
    bundle_info = isign.view(args.app_paths[0])
    print json.dumps(bundle_info, indent=4, separators=(',', ': '))