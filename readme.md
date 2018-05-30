# Fantom v1.0.71 for Windows
---
[![Written for: Fantom](http://img.shields.io/badge/written%20for-Fantom-lightgray.svg)](http://fantom-lang.org/)
[![Licence: ISC](http://img.shields.io/badge/licence-ISC-blue.svg)](https://choosealicense.com/licenses/isc/)



## Overview

Download the latest installer on the [Downloads Page](https://bitbucket.org/fantomfactory/fantom-windows-installer/downloads).

This is a Windows installer for the [Fantom](http://fantom-lang.org/) Programming Language. 

It installs Fantom 1.0.71, compete with SWT for 64 bit platforms, and sets all required environment variables.

Issues related to this installer may be reported on the [issues page](https://bitbucket.org/fantomfactory/fantom-windows-installer/issues?status=new&status=open).

![Installer Screenshot](https://bytebucket.org/fantomfactory/fantom-windows-installer/raw/tip/etc/screenshot.png)



## The Installer

The installer contains the standard Fantom distribution as available [here](https://bitbucket.org/fantom/fan-1.0/downloads/) and unpacks it into the selected directory.

The installer then sets and updates the `FAN_HOME` and `PATH` environment variables. If Fantom is installed for *"Just Me"* then the user's environment variables are set. If installed for *"All Users"* then the System environment variables are updated.



## What's in it?

This distribution differs slightly from the *official* distribution as this download also contains support for SWT / FWT on 64 bit Windows.

`etc/sys/config.props` has also been altered slighly:

 - `errTraceMaxDepth` has been increased from 25 to 50 to give longer stack traces
 - `debug` has been set to `true` to enable JVM debugging in IDE's like [F4](http://www.xored.com/products/f4/)

Also, this download doesn't contain those annoying `.DS_Store` junk files for MacOS!



## Fantom Work Directory

If you wish to keep your Fantom installation pristine and clean, then set up a work directory by setting these optional environment variables:

    set FAN_ENV=util::PathEnv
	set FAN_ENV_PATH=%UserProfile%\fantom-workDir

See [Path Env](http://fantom.org/doc/docLang/Env#PathEnv) for details.



## Pre-Requisites

The installer assumes the system already has Java installed. JRE 1.7 or later is required to run Fantom programs.



## Built by NSIS

The installer was created with [NSIS 3.02.1](http://nsis.sourceforge.net/Main_Page) and built with the [large strings](http://nsis.sourceforge.net/Special_Builds) variant to work around problems inherent with altering the `PATH` environment variable.

The `/SOLID lzma` compressor created the smallest installer.



## Licence

Fantom is licensed under the [Academic Free Licence](http://opensource.org/licenses/AFL-3.0) and this installer is licensed under the [ISC Licence](http://opensource.org/licenses/ISC).
