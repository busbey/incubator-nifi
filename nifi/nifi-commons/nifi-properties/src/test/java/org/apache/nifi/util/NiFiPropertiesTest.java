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
package org.apache.nifi.util;

import static org.junit.Assert.assertEquals;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.nio.file.Path;
import java.util.List;

import org.junit.Test;

public class NiFiPropertiesTest {

    @Test
    public void testProperties() {

        NiFiProperties properties = loadSpecifiedProperties("/NiFiProperties/conf/nifi.properties");

        assertEquals("UI Banner Text", properties.getBannerText());

        List<Path> directories = properties.getNarLibraryDirectories();

        assertEquals(new File("./target/resources/NiFiProperties/lib/").getPath(),
                directories.get(0).toString());
        assertEquals(new File("./target/resources/NiFiProperties/lib2/").getPath(), directories
                .get(1).toString());

    }

    @Test
    public void testMissingProperties() {

        NiFiProperties properties = loadSpecifiedProperties("/NiFiProperties/conf/nifi.missing.properties");

        List<Path> directories = properties.getNarLibraryDirectories();

        assertEquals(1, directories.size());

        assertEquals(new File(NiFiProperties.DEFAULT_NAR_LIBRARY_DIR).getPath(), directories.get(0)
                .toString());

    }

    @Test
    public void testBlankProperties() {

        NiFiProperties properties = loadSpecifiedProperties("/NiFiProperties/conf/nifi.blank.properties");

        List<Path> directories = properties.getNarLibraryDirectories();

        assertEquals(1, directories.size());

        assertEquals(new File(NiFiProperties.DEFAULT_NAR_LIBRARY_DIR).getPath(), directories.get(0)
                .toString());

    }

    private NiFiProperties loadSpecifiedProperties(String propertiesFile) {

        String file = NiFiPropertiesTest.class.getResource(propertiesFile).getFile();

        System.setProperty(NiFiProperties.PROPERTIES_FILE_PATH, file);

        NiFiProperties properties = NiFiProperties.getInstance();

        // clear out existing properties
        for (String prop : properties.stringPropertyNames()) {
            properties.remove(prop);
        }

        InputStream inStream = null;
        try {
            inStream = new BufferedInputStream(new FileInputStream(file));
            properties.load(inStream);
        } catch (final Exception ex) {
            throw new RuntimeException("Cannot load properties file due to "
                    + ex.getLocalizedMessage(), ex);
        } finally {
            if (null != inStream) {
                try {
                    inStream.close();
                } catch (final Exception ex) {
                    /**
                     * do nothing *
                     */
                }
            }
        }

        return properties;
    }

}
