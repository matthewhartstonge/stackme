#!/usr/bin/env bash
# Copyright (C) 2016, Mykro Enterprises New Zealand Limited.
# Copyright (C) 2016, Matthew Hartstonge <matt@mykro.co.nz> and other Authors.
# All rights reserved.
#
# Use of this source code is governed by a BSD 3-clause license that can be found
# in the LICENSE file.

# Alpine uses non-debian standards for www-data, so for the host we explicitly
# have to set files to uid/gid 82
mkdir -p dbdata
mkdir -p html
chown -R 82:82 html
mkdir -p logs
chown -R 82:82 logs

