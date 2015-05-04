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

NIFI_BUILT_PARENT=false

function nifiproject_private_build_parent
{
  local pom=$1
  ${GREP} -A 1 "nifi-parent" "${pom}" | ${GREP} "SNAPSHOT" >/dev/null
  if [[ $? == 0 ]]; then
    if [[ ${NIFI_BUILT_PARENT} == "true" ]]; then
      hadoop_debug "pom '${pom}' is based on a SNAPSHOT version of parent, but we already built it."
      return 0
    fi
    hadoop_debug "pom '${pom}' is based on a SNAPSHOT version of parent, building."
    echo_and_redirect "${PATCH_DIR}/nifi_${PATCH_BRANCH}_parent_JavacWarnings.txt" "${MVN}" --file nifi-parent/pom.xml install
    if [[ $? == 0 ]]; then
      NIFI_BUILT_PARENT=true
    else
      hadoop_error "nifi pom needs an updated parent SNAPSHOT build, but it failed."
      return 1
    fi
  fi
}

## @description once checkout is done, change to the subproject
function nifiproject_postcheckout
{
  local parent_built=false
  if [[ "nifi" == ${NIFI_SUBPROJECT} ]]; then
    nifiproject_private_build_parent 'nifi/pom.xml'
    if [[ $? != 0 ]]; then
      return 1
    fi
    ${GREP} -A 1 "nifi-nar-maven-plugin" nifi/pom.xml | ${GREP} "SNAPSHOT" >/dev/null
    if [[ $? == 0 ]]; then
      hadoop_debug "nifi pom is based on a SNAPSHOT version of nifi-nar-plugin, building."
      nifiproject_private_build_parent 'nifi-nar-maven-plugin/pom.xml'
      if [[ $? != 0 ]]; then
        return 1
      fi
      echo_and_redirect "${PATCH_DIR}/nifi_${PATCH_BRANCH}_nar-plugin_JavacWarnings.txt" "${MVN}" --file nifi-nar-maven-plugin/pom.xml install
      if [[ $? != 0 ]]; then
        hadoop_error "nifi pom needs an updated nar-plugin SNAPSHOT build, but it failed."
        return 1
      fi
    fi
  fi
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
