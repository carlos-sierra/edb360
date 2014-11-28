/*****************************************************************************************
   
    EDB360 - Enkitec's Oracle Database 360-degree View
    Copyright (C) 2014  Carlos Sierra

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

*****************************************************************************************/
PRO Please wait ...
@@sql/esp_collect_requirements.sql
HOS zip -qmT esp_requirements_&&esp_host_name_short..zip esp_requirements_&&esp_host_name_short..csv esp_requirements_&&esp_host_name_short..log cpuinfo_model_name.txt
@@sql/edb360_0a_main.sql
HOS zip -qmT &&main_compressed_filename._&&file_creation_time. esp_requirements_&&esp_host_name_short..zip 
HOS unzip -l &&main_compressed_filename._&&file_creation_time.
