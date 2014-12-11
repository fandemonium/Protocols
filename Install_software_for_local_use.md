Install and execute softwares without root permission
-----

This is really useful when running/testing softwares on machines you have no control of, e.g. clusters. Here I use install new apache-ant on Lighting3 (a redhat cluster) as an example:

1. Lignthing3 has ant installed but it's an older version and java compiler does not like it...So I need to install a newer version.   

2. Apache-ant comes with binary version, which is awesome! All you need to do is to download it from [here](http://ant.apache.org/bindownload.cgi). I used `wget` to get the tar ball directly.   
    ```
    wget http://mirror.cogentco.com/pub/apache//ant/binaries/apache-ant-1.9.4-bin.tar.gz
    ```

3. `cd` into the directory and there should be a folder called 'bin'. If it's not there, you downloaded the wrong thing...   

4. It is required to set `ANT_HOME`. You can do this every time you need to use ant in terminal or set it up in `.cshrc` so that no future manual work is needed.   
    ```
    vi ~/.cshrc 
    ```

    NOTE: you don't have to use vi. Use whatever you have to edit (create if it doesn't exit) `.cshrc`. File `.cshrc` has to reside in your home directory. 

5. In the opened `.cshrc`, add the following lines:
    ```
    setenv ANT_HOME /PATH/TO/WHERE/ANT/IS/apache-ant-1.9.4   
    setenv PATH $ANT_HOME/bin:$PATH   
    ```

    NOTE: the first line sets the ANT_HOME. The second line sets the software path upon logging in and open a new terminal remotely every time. 

6. Save and get back to your terminal window.  

7. Try `which ant`. The pathway should point towards your new apache-ant-1.9.4.

8. If you type `ant -version`, it should return:   
    ```
    Apache Ant(TM) version 1.9.4 compiled on April 29 2014
    ```

9. DONE!

FINAL NOTE:  
Everything else is similar. Python requires a bit of more work and there are a couple of ways to do it. Briefly, one as below:  
1. after untar the source tarball, do:
    ```
    ./configure
    ```

2. Make altinstall prefix=/PATH/TO/WHERE/I/WANT/IT exec-prefix=/PATH/TO/WHERE/I/WANT/IT   

3. The install python directory now should have folders `bin`, `lib`, and `include`.   
    1. `bin` contains executable `python2.X`   
    2. `lib` includes packages and modules   
    3. `include` includes development headers   

4. You will have to link executable `python2.X` to `python`!   
    ```
    ln -s python2.X python
    ```

5. Set PYTHONHOME and PYTHONPATH in `.cshrc`. Below is what I put down:   
    ```
    #python 2.7.6
    setenv PYTHONHOME $tools/Python2.7.8
    setenv PYTHONPATH $PYTHONHOME/bin
    setenv PATH $PYTHONPATH/:$PATH
    #python dev-headers and modules
    setenv PYTHONPATH $PYTHONHOME/include/python2.7/:$PYTHONHOME/lib/python2.7/:$PYTHONPATH
    ```

    NOTE: you will have to include the path to headers and pacakges!

6. Like `ant`, check `python` path and version to confirm.   

7. When installing python modules, double check module installation. But it can usually be carried out like follow:  
    ```
    python setup.py build
    python setup.py install --prefix=/WHERE/MY/PYTHONHOME/IS
    ```


    NOTE: you will have to include the path to headers and pacakges!

6. Like `ant`, check `python` path and version to confirm.   

7. When installing python modules, double check module installation. But it can usually be carried out like follow:  
    ```
    python setup.py build
    python setup.py install --prefix=/WHERE/MY/PYTHONHOME/IS
    ```


    NOTE: you will have to include the path to headers and pacakges!

6. Like `ant`, check `python` path and version to confirm.   

7. When installing python modules, double check module installation. But it can usually be carried out like follow:  
    ```
    python setup.py build
    python setup.py install --prefix=/WHERE/MY/PYTHONHOME/IS
    ```


    NOTE: you will have to include the path to headers and pacakges!

6. Like `ant`, check `python` path and version to confirm.   

7. When installing python modules, double check module installation. But it can usually be carried out like follow:  
    ```
    python setup.py build
    python setup.py install --prefix=/WHERE/MY/PYTHONHOME/IS
    ```


    NOTE: you will have to include the path to headers and pacakges!

6. Like `ant`, check `python` path and version to confirm.   

7. When installing python modules, double check module installation. But it can usually be carried out like follow:  
    ```
    python setup.py build
    python setup.py install --prefix=/WHERE/MY/PYTHONHOME/IS
    ```


    NOTE: you will have to include the path to headers and pacakges!

6. Like `ant`, check `python` path and version to confirm.   

7. When installing python modules, double check module installation. But it can usually be carried out like follow:  
    ```
    python setup.py build
    python setup.py install --prefix=/WHERE/MY/PYTHONHOME/IS
    ```


    NOTE: you will have to include the path to headers and pacakges!

6. Like `ant`, check `python` path and version to confirm.   

7. When installing python modules, double check module installation. But it can usually be carried out like follow:  
    ```
    python setup.py build
    python setup.py install --prefix=/WHERE/MY/PYTHONHOME/IS
    ```


    NOTE: you will have to include the path to headers and pacakges!

6. Like `ant`, check `python` path and version to confirm.   

7. When installing python modules, double check module installation. But it can usually be carried out like follow:  
    ```
    python setup.py build
    python setup.py install --prefix=/WHERE/MY/PYTHONHOME/IS
    ```


    NOTE: you will have to include the path to headers and pacakges!

6. Like `ant`, check `python` path and version to confirm.   

7. When installing python modules, double check module installation. But it can usually be carried out like follow:  
    ```
    python setup.py build
    python setup.py install --prefix=/WHERE/MY/PYTHONHOME/IS
    ```

8. Modules should then be installed into Your/python/lib/site-packages. 

