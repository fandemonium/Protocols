[fyang@hpc5 apache-ant-1.9.4]$ cd bin/
[fyang@hpc5 bin]$ ls
ant      ant.cmd     antRun      antRun.pl            envset.cmd  runant.pl  runrc.cmd
ant.bat  antenv.cmd  antRun.bat  complete-ant-cmd.pl  lcp.bat     runant.py
[fyang@hpc5 bin]$ ant
Error: Could not find or load main class org.apache.tools.ant.launch.Launcher
[fyang@hpc5 bin]$ setenv ANT_HOME:/data004/software/EEOB/khoflab/apache-ant-1.9.4/bin
setenv: Variable name must contain alphanumeric characters.
[fyang@hpc5 bin]$ setenv ANT_HOME=/data004/software/EEOB/khoflab/apache-ant-1.9.4/bin
setenv: Variable name must contain alphanumeric characters.
[fyang@hpc5 bin]$ vi ~/.cs
.cshrc~     .cshrc*     .cshrc.bak  
[fyang@hpc5 bin]$ vi ~/.cshrc
[fyang@hpc5 bin]$ ls
ant      ant.cmd     antRun      antRun.pl            envset.cmd  runant.pl  runrc.cmd
ant.bat  antenv.cmd  antRun.bat  complete-ant-cmd.pl  lcp.bat     runant.py
[fyang@hpc5 bin]$ cd ..
[fyang@hpc5 apache-ant-1.9.4]$ ls
bin  fetch.xml   INSTALL  lib      manual  README
etc  get-m2.xml  KEYS     LICENSE  NOTICE  WHATSNEW
[fyang@hpc5 apache-ant-1.9.4]$ setenv ANT_HOME /data004/software/EEOB/khoflab/apache-ant-1.9.4
[fyang@hpc5 apache-ant-1.9.4]$ set path=( $path $ANT_HOME/bin )
[fyang@hpc5 apache-ant-1.9.4]$ which ant
/data004/software/EEOB/khoflab/apache-ant-1.9.4/bin/ant
[fyang@hpc5 apache-ant-1.9.4]$ 
[fyang@hpc5 apache-ant-1.9.4]$ ant
Buildfile: build.xml does not exist!
Build failed
[fyang@hpc5 apache-ant-1.9.4]$ ant -version
Apache Ant(TM) version 1.9.4 compiled on April 29 2014

