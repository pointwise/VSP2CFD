# VSP2CFD
Copyright 2021 Cadence Design Systems, Inc. All rights reserved worldwide.

A Glyph script to generate a viscous mesh for VSP generated surface grids. 

![ScriptImage](https://raw.github.com/pointwise/VSP2CFD/master/ScriptImage.png)

## Usage
This script will import a surface mesh generated using OpenVSP and create an unstructured viscous mesh using T-Rex. The parameters driving the meshing process can be found within VSP2CFD.glf under the section titled *User Defined Parameters.* The user has control over the size and resolution of the farfield, the boundary layer meshing parameters, and quality constraints.

Once the script has finished, a Pointwise project file will be saved to the working directory. The filename of the .pw file has the same base name as the OpenVSP surface grid and is appended with *-Grid*. 

## Disclaimer
This file is licensed under the Cadence Public License Version 1.0 (the "License"), a copy of which is found in the LICENSE file, and is distributed "AS IS." 
TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, CADENCE DISCLAIMS ALL WARRANTIES AND IN NO EVENT SHALL BE LIABLE TO ANY PARTY FOR ANY DAMAGES ARISING OUT OF OR RELATING TO USE OF THIS FILE. 
Please see the License for the full text of applicable terms.
