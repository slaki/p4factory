#!/usr/bin/env python
"""
This script is intended to set up an environment suitable for 
building and running P4 programs. 

Supported host platforms

- Ubuntu 14.04

Supported targets

- P4 Behavioral Model
- Tofino Architectural Model (with access to proper repositories)
- Tofino Device Target (with access to proper repositories)

This script must be executed with sudo privileges

"""

import sys
import os
import stat
import subprocess
import argparse
from collections import OrderedDict

global trial_run
trial_run = False

# @FIXME Support specifying subdirectory
def run_command(cmd, cwd=None):
    """
    Run the command and return output
    Call error_occurred if exception
    """
    if trial_run:
        sys.stdout.write("[DryRun]: %s\n" % " ".join(cmd))
        return None

    sys.stderr.write("[Run]: %s\n" % " ".join(cmd))
    try:
        p1 = subprocess.Popen(cmd, stdout=subprocess.PIPE, cwd=cwd)
        result = p1.communicate()[0]
        if p1.wait() != 0:
            error_occurred("Bad return code for cmd", cmd=cmd, result=result)
    except:
        e = sys.exc_info()[0]
        sys.stderr.write("An error occured running %s: %s" %
                         (" ".join(cmd), str(e)))
        sys.exit(1)

    return result

def apt_get_install(pkg):
    """
    Install pkg using APT

    @param pkg The name of the pkg to install
    """
    run_command(["apt-get", "install", "-y", pkg])

def pip_install(pkg):
    """
    Install pkg with the Python installer

    @param pkg The name of the pkg to install
    """
    run_command(["pip", "install", pkg])

def script_install(script):
    """
    Install a pkg according to the indicated script

    @param script An array of strings, each a command
    """
    # Write the script out to a tmp file
    tmp_filename = "/tmp/bootstrap_script.sh"
    with open(tmp_filename, "w") as f:
        f.write(script)
    st = os.stat(tmp_filename)
    os.chmod(tmp_filename, st.st_mode | stat.S_IEXEC)

    run_command([tmp_filename])

def build_from_source(dir_name, get_cmd, unpack_cmd=None):
    """
    Run get command, then cd to dir_name and do the usual
    "configure; make; make install"

    @param dir_name The directory where build is done
    @param get_cmd May be a string or an array as per input to submodule
    @param unpack_cmd The command to unpack after download
    """
    if isinstance(get_cmd, str):
        get_cmd = get_cmd.split()
    run_command(pkg)
    if unpack_cmd:
        if isinstance(unpack_cmd, str):
            unpack_cmd = unpack_cmd.split()
        run_command(unpack_cmd)
    run_command(["./configure"], cwd=dir_name)
    run_command(["make"], cwd=dir_name)
    run_command(["make", "install"], cwd=dir_name)

# this is the script to install thrift from source.
# Assumes sudo 
thrift_install_script = """#!/bin/sh
mkdir thrift
cd thrift
wget http://www.gtlib.gatech.edu/pub/apache/thrift/0.9.1/thrift-0.9.1.tar.gz
tar xvzf thrift-0.9.1.tar.gz
cd thrift-0.9.1
./configure
cd test/cpp ; ln -s . .libs ; cd ../..
sudo make install
sudo ldconfig
"""

vxlan_scapy_script = """#!/bin/sh
git clone https://github.com/barefootnetworks/scapy-vxlan.git
cd scapy-vxlan
sudo python setup.py install
"""


# Package list structure. Each entry is a map from:
#   name : the name of the package
#   platforms : If present, the list of host platforms on which to execute
#   installer : A pointer to a function that takes the pkg name
#   params : Params conveyed to the installer; if not present,
# the name of the package is used.
#
# Packages are installed in the order listed here, so any
# relative dependencies should be given here

package_list = OrderedDict()
package_list["automake"] = { "installer" : apt_get_install }
package_list["bison"] = { "installer" : apt_get_install }
package_list["doxygen"] = { "installer" : apt_get_install }
package_list["ethtool"] = { "installer" : apt_get_install }
package_list["flex"] = { "installer" : apt_get_install }
package_list["g++"] = { "installer" : apt_get_install }
package_list["git"] = { "installer" : apt_get_install }
package_list["ipython"] = { "installer" : apt_get_install }
package_list["ipython-notebook"] = { "installer" : apt_get_install }
package_list["libboost1.54-dev"] = { "installer" : apt_get_install }
package_list["libboost-filesystem-dev"] = { "installer" : apt_get_install }
package_list["libboost-program-options-dev"] = { "installer" : apt_get_install }
package_list["libboost-system-dev"] = { "installer" : apt_get_install }
package_list["libboost-test-dev"] = { "installer" : apt_get_install }
package_list["libedit-dev"] = { "installer" : apt_get_install }
package_list["libevent-dev"] = { "installer" : apt_get_install }
package_list["libfreetype6-dev"] = { "installer" : apt_get_install }
package_list["libhiredis-dev"] = { "installer" : apt_get_install }
package_list["libjudy-dev"] = { "installer" : apt_get_install }
package_list["libpcap-dev"] = { "installer" : apt_get_install }
package_list["libpng-dev"] = { "installer" : apt_get_install }
package_list["libssl-dev"] = { "installer" : apt_get_install }
package_list["libtool"] = { "installer" : apt_get_install }
package_list["libyaml-0-2"] = { "installer" : apt_get_install }
package_list["mininet"] = { "installer" : apt_get_install }
package_list["pkg-config"] = { "installer" : apt_get_install }
package_list["python-dev"] = { "installer" : apt_get_install }
package_list["python-dpkt"] = { "installer" : apt_get_install }
package_list["python-imaging-tk"] = { "installer" : apt_get_install }
package_list["python-matplotlib"] = { "installer" : apt_get_install }
package_list["python-nose"] = { "installer" : apt_get_install }
package_list["python-numpy"] = { "installer" : apt_get_install }
package_list["python-pandas"] = { "installer" : apt_get_install }
package_list["python-pip"] = { "installer" : apt_get_install }
package_list["python-pygraph"] = { "installer" : apt_get_install }
package_list["python-pygraphviz"] = { "installer" : apt_get_install }
package_list["python-scapy"] = { "installer" : apt_get_install }
package_list["python-scipy"] = { "installer" : apt_get_install }
package_list["python-setuptools"] = { "installer" : apt_get_install }
package_list["python-sympy"] = { "installer" : apt_get_install }
package_list["python-thrift"] = { "installer" : apt_get_install }
package_list["python-yaml"] = { "installer" : apt_get_install }
package_list["redis-server"] = { "installer" : apt_get_install }
package_list["thrift-compiler"] = { "installer" : apt_get_install }
package_list["wireshark"] = { "installer" : apt_get_install }

package_list["jsonpickle"] = { "installer" : pip_install }
#package_list["matplotlib"] = { "installer" : pip_install }
package_list["networkx"] = { "installer" : pip_install }
package_list["numpy"] = { "installer" : pip_install }
package_list["ply"] = { "installer" : pip_install }
package_list["pygraphviz"] = { "installer" : pip_install }
package_list["pyparsing"] = { "installer" : pip_install }
#package_list["pypcap"] = { "installer" : pip_install }
#package_list["pyyaml"] = { "installer" : pip_install }
package_list["termcolor"] = { "installer" : pip_install }

package_list["thrift-source"] = { "installer" : script_install,
                                  "params" : thrift_install_script }

package_list["vxlan-scapy"] = { "installer" : script_install,
                                  "params" : vxlan_scapy_script }


def deref_or_none(map, key, dflt=None):
    if key in map:
        return map[key]
    return dflt

if __name__ == "__main__":
    desc = "Install packages for P4 build env"
    usage = "%(prog)s [options]"
    parser = argparse.ArgumentParser(description=desc, usage=usage)
    parser.add_argument('-n', '--trial_run', action="store_true",
                        help="Do not run commands")

    args = parser.parse_args()

    trial_run = args.trial_run

    for name, vals in package_list.items():
        params = deref_or_none(vals, "params", dflt=name)
        vals["installer"](params)
