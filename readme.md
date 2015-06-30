# Fantom v1.0.67 for Windows
---
[![Written for: Fantom](http://img.shields.io/badge/written%20for-Fantom-lightgray.svg)](http://fantom.org/)
![Licence: ISC](http://img.shields.io/badge/licence-ISC-blue.svg)



## Overview

This is a Windows installer for the [Fantom Programming Language](http://fantom.org/). 

It installs Fantom on 32 bit and 64 bit systems, for normal users and admin users.

![Installer Screenshot](https://bitbucket.org/repo/bdR87g/images/2143016538-screenshot.png)

Download the latest installer on the [downloads page](https://bitbucket.org/fantomfactory/fantom-installer/downloads).

Issues and bugs related to this installer to be reported on the [issues page](https://bitbucket.org/fantomfactory/fantom-installer/issues?status=new&status=open).



## The Installer

The installer contains the standard Fantom distribution as available [here](https://bitbucket.org/fantom/fan-1.0/downloads/) and unpacks it into the selected directory.

The installer then sets and updates the `FAN_HOME` and `PATH` environment variables. If Fantom is installed for *"just me"* then the user's environment variables are set. If installed for *"All Users"* then the System environment variables are updated.

If installed on a 64 bit system then a 64 bit version of the `swt.jar` is installed into the `lib\java\ext\win32-x86_64` directory, and all `\bin\*.exe` files are replaced with `*.cmd` files. See [Fantom on Windows 64-Bit](http://www.fantomfactory.org/articles/fantom-on-windows-64-bit) for details.

### Fantom Work Directory

If you wish to keep your Fantom installation pristine and clean, then set up a work directory by setting these optional environment variables:

    set FAN_ENV=util::PathEnv
	set FAN_ENV_PATH=%UserProfile%\fantom-workDir

See [Path Env](http://fantom.org/doc/docLang/Env#PathEnv) for details.



## Pre-Requisites

The assumes the system already has Java installed. JRE 1.6 or later is required to run Fantom programs.



## Built by NSIS

The installer was created with [NSIS 3.0b1](http://nsis.sourceforge.net/Main_Page) and built with the [large strings](http://nsis.sourceforge.net/Special_Builds) variant to work around problems inherent with altering the `PATH` environment variable.

The `/SOLID lzma` compressor created the smallest installer (10,480,454 bytes).



## Licence

Fantom is licensed under the [Academic Free Licence](http://opensource.org/licenses/AFL-3.0) and this installer is licensed under the [ISC Licence](http://opensource.org/licenses/ISC).