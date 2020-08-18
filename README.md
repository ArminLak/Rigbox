----------
# Rigbox
![Coverage badge](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fsilent-zebra-36.tunnel.datahub.at%2Fcoverage%2Frigbox%2Fmaster)
![Build status badge](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fsilent-zebra-36.tunnel.datahub.at%2Fstatus%2Frigbox%2Fmaster)

Rigbox is a high-performance, open-source MATLAB toolbox for managing behavioral neuroscience experiments. Rigbox's main goals are to simplify hardware/software interfacing, behavioral task design, and visual and auditory stimuli presentation. Additionally, Rigbox can time-align datastreams from multiple sources and communicate with a remote database to manage experiment data. Rigbox is mostly object-oriented and highly modular, which simplifies the process of designing experiments. For detailed information, see [the publication](https://www.biorxiv.org/content/10.1101/672204v3). 

## Requirements

For exploring Rigbox's features and running test experiments, Rigbox only needs to be installed on a single computer.

For running full experiments, Rigbox should be installed on two computers: one computer (which we refer to as the "Stimulus Computer" or "SC") communicates with an experiment rig's hardware and presents stimuli, and the other computer (which we refer to as the "Master Computer" or "MC") runs a GUI that the experimenter can use to start, monitor, parameterize, and stop the experiment.

### Hardware

Below are the **minimum** computer hardware specs:
* CPU: 4 logical processors @ 3.0 GHz base speed (e.g. Intel Core i5-6500)
* RAM: DDR4 16 GB @ 2133 MHz (e.g. Corsair Vengeance 16 GB)
* GPU: 2 GB @ 1000 MHz base and memory speed (e.g. NVIDIA Quadro P400)

For most experiments, typical, contemporary, factory-built desktops running Windows 10 with dedicated graphics cards should suffice. Specific requirements of a SC will depend on the complexity of the experiment. For example, running an audio-visual integration task on multiple screens will require quality graphics and sound cards. SCs may additionally require an i/o device to communicate with external rig hardware, of which currently only National Instruments Data Acquisition Devices (NI-DAQs, e.g. NI-DAQ USB 6211) are supported.

<<<<<<< HEAD
0. It is highly recommended to install Rigbox via git. If not already downloaded and installed, install [git](https://git-scm.com/download/win) (and the included minGW software environment and Git Bash MinTTY terminal emulator). After installing, launch the Git Bash terminal. 
1. To install Rigbox, run the following commands in the Git Bash terminal to clone the repository from GitHub to your local machine.  (* *Note*: It is *not* recommended to clone directly into the MATLAB folder)
```
git clone --recurse-submodules https://github.com/arminlak/Rigbox
```
2. Open MATLAB and run `addRigboxPaths.m` then restart the program.  *Note*: Do __not__ add all Rigbox folders and subfolders to the paths! 
3. Set the correct paths on both computers by following the instructions in the '/docs/setup/paths_config' file.
4. On the stimulus computer, set the hardware configuration by following the instructions in the '/docs/setup/hardware_config' file.
5. To keep the submodules up to date, run the following in the Git Bash terminal (within the Rigbox directory):
```
git pull --recurse-submodules
```

### Running an experiment in MATLAB

On the stimulus computer, run:
> srv.expServer

On the master computer, run:
> mc

This opens the MC GUI for selecting a subject, experiment, and the SC on which to run the experiment. The MC GUI also allows for editing some experimental parameters and logging into the Alyx database. To launch the experiment on the selected SC, press 'Start'.

## Code organization

Below is a list of Rigbox's subdirectories and an overview of their respective contents.

### +dat

The "data" package contains code pertaining to the organization and logging of data. It contains functions that generate and parse unique experiment reference ids, and return file paths where subject data and rig configuration information is stored. Other functions include those that manage experimental log entries and parameter profiles. A nice metaphor for this package is a lab notebook.

### +eui

The "user interface" package contains code pertaining to the Rigbox user interface. It contains code for constructing the mc GUI (MControl.m), and for plotting live experiment data or generating tables for viewing experiment parameters and subject logs. 

This package is exclusively used by the master computer.

### +exp
=======
### Software
>>>>>>> cortexlab/master

Below are the **minimum** computer software dependencies that must be installed before installing Rigbox:

* OS: 64 Bit Windows 10
* Libraries: Visual C++ Redistributable Packages for Visual Studio [2013](https://www.microsoft.com/en-us/download/details.aspx?id=40784) & [2015](https://www.microsoft.com/en-us/download/details.aspx?id=48145)
* MATLAB: [2018b or later](mathworks.com/downloads/), including the Data Acquisition Toolbox
* Community MATLAB toolboxes:
	* [GUI Layout Toolbox](https://uk.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox) (v2 or later)
	* [Psychophysics Toolbox](http://psychtoolbox.org/download.html#Windows) (v3 or later)

Similar to the hardware requirements, software requirements for a SC will depend on the experiment: if acquiring data through a NI-DAQ, the SC will additionally require the MATLAB [NI-DAQmx support package](https://uk.mathworks.com/hardware-support/nidaqmx.html).

## Installation

Before starting, ensure you have read and installed the above [requirements](#requirements). You can also install these requirements (after following step 1 below) by running the `installRigboxReqs` function in MATLAB, and following the instructions that appear in the MATLAB command window.

Below we provide brief instructions for installing Rigbox via Git. These instructions explain how to 1) clone the repository from GitHub to your computer, and 2) appropriately add Rigbox to MATLAB's paths. For a detailed installation guide, including installing Rigbox's software requirements, see [here](https://cortex-lab.github.io/Rigbox/detailed_installation.html).

1. In your git terminal, run:
```
git clone --recurse-submodules https://github.com/cortex-lab/Rigbox
```

2. In MATLAB, navigate to the Rigbox root directory (where Rigbox was cloned), and run:
`addRigboxPaths()`, OR `addRigboxPaths('SavePaths', false)` if you don't want to save the paths for future MATLAB sessions. 
(*Note*: Do **not** manually add all Rigbox folders and subfolders to the paths.)

## Getting started

To ensure the installation completed successfully, try running the [example experiments from the Rigbox paper](https://cortex-lab.github.io/Rigbox/paper_examples.html).

Rigbox uses the [*Signals*](https://github.com/cortex-lab/signals) framework for programatically designing and running behavioral tasks. See the *Signals* [docs](https://github.com/cortex-lab/signals/tree/master/docs) for more information on *Signals* and how to run example test experiments on a single computer via Rigbox's `+eui/SignalsTest.m` GUI.

![](https://github.com/cortex-lab/Rigbox/blob/master/docs/html/images/SignalsTest%20GUI%20Example.gif)
(The above is an example of running the `signals/docs/examples/exp defs/advancedChoiceWorld.m` file in the `+eui/SignalsTest.m` GUI.)

Rigbox's online documentation, including detailed set-up and usage guides for running experiments on a MC and SC, can be found at [cortex-lab.github.io/Rigbox](https://cortex-lab.github.io/Rigbox/).

## Updating the code

With Git it's very easy to keep the code up-to-date. We strongly recommend regularly updating Rigbox and its submodules by running the following git command (within the Rigbox directory):
```
git pull --recurse-submodules
```

## Contributing

If you experience a bug or have a feature request, please report it via [github Issues](https://github.com/cortex-lab/Rigbox/issues). For details on contributing code and our code of conduct, please see our [contributing page](https://github.com/cortex-lab/Rigbox/blob/master/CONTRIBUTING.md).

## Authors & Accreditation

Rigbox was created by [Chris Burgess](https://github.com/dendritic/) in 2013, initially developed to probe mouse behavior for the [Steering Wheel Setup](https://www.ucl.ac.uk/cortexlab/tools/wheel). It is now maintained and developed by Miles Wells (miles.wells@ucl.ac.uk), Jai Bhagat (j.bhagat@ucl.ac.uk) and a number of others at [CortexLab](https://www.ucl.ac.uk/cortexlab). See also the full list of [contributors](https://github.com/cortex-lab/Rigbox/graphs/contributors).

Please cite [the Rigbox publication](https://www.biorxiv.org/content/10.1101/672204v3) appropriately in publications which use Rigbox to run behavioral tasks and/or acquire data.

## Acknowledgements

* [GUI Layout Toolbox](https://uk.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox) for code pertaining to Rigbox's UI
* [Psychophysics Toolbox](http://psychtoolbox.org) for code pertaining to visual stimulus presentation
* [NI-DAQmx](https://uk.mathworks.com/hardware-support/nidaqmx.html) for code pertaining to inerfacing with a NI-DAQ device
* [TooTallNate](https://github.com/TooTallNate/Java-WebSocket) for code pertaining to using Java Websockets
* [Timothy E. Holy](http://holylab.wustl.edu/) for the `distinguishable_colors` function