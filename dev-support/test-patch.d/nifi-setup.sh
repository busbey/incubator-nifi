#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

add_plugin nifiproject

NIFI_SUBPROJECT=""

## @description after we check out the code, we need to determine which
## @description subproject changes are for.
function nifiproject_filefilter
{
  local filename=$1
  local subproject
  local pattern

  hadoop_debug "patch changes file ${filename}."
  for subproject in nifi nifi-parent nifi-nar-maven-plugin
  do
    pattern="^${subproject}/"
    hadoop_debug "checking against subproject pattern ${pattern}"
    if [[ ${filename} =~ $pattern ]]; then
      hadoop_debug "changed file matches subproject ${subproject}"
      if [[ -z ${NIFI_SUBPROJECT} ]]; then
        NIFI_SUBPROJECT="${subproject}"
      elif [[ ${NIFI_SUBPROJECT} != "${subproject}" ]]; then
        hadoop_error "the patch appears to apply to both the subprojects '${subproject}' and '${NIFI_SUBPROJECT}'. Please ensure it only applies to one."
        return 1
      fi
    fi
  done
}

## @description once checkout is done, change to the subproject
function nifiproject_postcheckout
{
  if [[ -n ${NIFI_SUBPROJECT} ]]; then
    hadoop_debug "changing into subproject ${NIFI_SUBPROJECT}"
    pushd "${NIFI_SUBPROJECT}"
  fi
}

## @description to apply the patch we need to be in the top level
function nifiproject_preapply
{
  if [[ -n ${NIFI_SUBPROJECT} ]]; then
    hadoop_debug "changing back to top level to apply patch"
    popd
  fi
}

## @description after applying the patch, go back to subproject
function nifiproject_postapply
{
  if [[ -n ${NIFI_SUBPROJECT} ]]; then
    hadoop_debug "changing into subproject ${NIFI_SUBPROJECT}"
    pushd "${NIFI_SUBPROJECT}"
  fi
}

## @description XXX we probably need a posttest
function nifiproject_tests
{
  if [[ -n ${NIFI_SUBPROJECT} ]]; then
    hadoop_debug "changing back to top level"
    popd
  fi
}
