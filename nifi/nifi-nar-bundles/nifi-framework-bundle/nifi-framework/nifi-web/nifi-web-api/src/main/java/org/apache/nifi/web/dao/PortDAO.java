/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.nifi.web.dao;

import java.util.Set;

import org.apache.nifi.connectable.Port;
import org.apache.nifi.web.api.dto.PortDTO;

public interface PortDAO {

    /**
     * @param groupId group id
     * @param portId port id
     * @return Determines if the specified port exists in the specified group
     */
    boolean hasPort(String groupId, String portId);

    /**
     * Creates a port in the specified group.
     *
     * @param groupId group id
     * @param portDTO The port DTO
     * @return The port
     */
    Port createPort(String groupId, PortDTO portDTO);

    /**
     * Gets the specified port in the specified group.
     *
     * @param groupId group id
     * @param portId The port id
     * @return The port
     */
    Port getPort(String groupId, String portId);

    /**
     * Gets all of the ports in the specified group.
     *
     * @param groupId group id
     * @return The ports
     */
    Set<Port> getPorts(String groupId);

    /**
     * Verifies the specified port can be updated per the specified request.
     *
     * @param groupId group id
     * @param portDTO port
     */
    void verifyUpdate(String groupId, PortDTO portDTO);

    /**
     * Updates the specified port in the specified group.
     *
     * @param groupId group
     * @param portDTO The port DTO
     * @return The port
     */
    Port updatePort(String groupId, PortDTO portDTO);

    /**
     * Verifies the specified port can be removed.
     *
     * @param groupId group id
     * @param portId port id
     */
    void verifyDelete(String groupId, String portId);

    /**
     * Deletes the specified label in the specified group.
     *
     * @param groupId group id
     * @param portId The port id
     */
    void deletePort(String groupId, String portId);
}
