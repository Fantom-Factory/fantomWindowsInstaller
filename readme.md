# Fantom Installer v1.0.67
---
[![Written for: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom.org/)
![Licence: MIT](http://img.shields.io/badge/licence-MIT-blue.svg)



## Overview

This is a Windows installer for the Fantom Programming Language. 

It installs Fantom on 32 bit and 64 bit systems, for normal users and admin users.

![Installer Screenshot](https://bitbucket.org/repo/bdR87g/images/2143016538-screenshot.png)

Download the latest installer on the [downloads page](https://bitbucket.org/fantomfactory/fantom-installer/downloads).

Issues and bugs to be reported on the [issues page](https://bitbucket.org/fantomfactory/fantom-installer/issues?status=new&status=open).



## Specifics

The installer is sensitive to 32 and 64 bit systems and will only install the ...



## Built by NSIS

The installer was created with [NSIS 3.0b1](http://nsis.sourceforge.net/Main_Page) and built with the [large strings](http://nsis.sourceforge.net/Special_Builds) variant to work around problems inherient with altering the `PATH` environment variable.

The `/SOLID lzma` compressor created the smallest installer (10,480,454 bytes).
