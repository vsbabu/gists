# This is how I got Leo Outliner (https://leo-editor.github.io/leo-editor/) installed and usable in Windows 11, with dependencies.

### Step 1 - Anaconda
# install anaconda from https://www.anaconda.com/download
# Start -> Anaconda Powershell prompt

### Step 2 - get Leo
# get leo git repository into apps/leo-editor home directory 
# if you don't have git, download from URL below as zip and extract
cd $HOME
mkdir apps
cd apps
git clone https://github.com/leo-editor/leo-editor

### Step 3 - download Visual Studio build tools. This is needed to support PyQt5, which is a dependency for Leo
# Download https://aka.ms/vs/17/release/vs_BuildTools.exe and run. Choose the first option - develop C++ applications - and install. 
# This will take a little under 1.8GB to download and install.

### Step 4 - create a new Python env for leo and install dependencies 
conda create -n leo
conda activate leo
conda install python
pip install sphinx docutils PyEnchant PyQt5
# test out by
cd leo-editor
python launchLeo.py

### Step 5 - create a shortcut to start
# create a new shortcut with the path as below. This will open a cmd window also, you might want to check the "open as minimized". 
# you can get an icon from leo-editor\leo\Icons
C:\ProgramData\anaconda3\condabin\conda.bat run --no-capture-output --cwd %userprofile% -n leo pythonw.exe %userprofile%\Apps\leo-editor\launchLeo.py
