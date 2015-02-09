Targets Directory for P4 Model and Build repository
==========

This directory contains a target for each supported P4 program.
In addition:

+ common: Contains make files common to all such targets
+ templates: Contains files that are processed and copied into a new
target when it is produced.

In general, editing files in common will result in changes for all build
targets. To affect the configuration of a single target, edit the file
<proj-name>-local.mk in that project's directory. It will be read into
the top level make file.

Details
-------

TBD. Talk about installation requirements, global variable names
(P4_INPUT, etc), common.mk, behavioral.mk, dependency on build infra
structure, how to build the behavioral model....

For the behavioral model, each P4 program needs source code specific
to the program. This is done by creating a normal BigCode/Infra 
module under p4model/modules directory (to get the build plumbing correct)
and then installing the generated code in that module. The name of the
automatically created module file is <P4-program-name>_sim.

To make it easier for code common to different targets to be written,
public includes are placed in the directory inc/p4_sim. The inc directory
will be listed in the -I for the project, so common code may, for example:

    #include <p4_sim/pd.h> 

