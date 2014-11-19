# VSP2CFD
A Glyph script to generate a viscous mesh for VSP generated surface grids. 

![ScriptImage](https://raw.github.com/pointwise/VSP2CFD/master/ScriptImage.png)

## Usage
This script will import a surface mesh generated using OpenVSP and create an unstructured viscous mesh using T-Rex. The parameters driving the meshing process can be found within VSP2CFD.glf under the section titled *User Defined Parameters.* The user has control over the size and resolution of the farfield, the boundary layer meshing parameters, and quality constraints.

Once the script has finished, a Pointwise project file will be saved to the working directory. The filename of the .pw file has the same base name as the OpenVSP surface grid and is appended with *-Grid*. 

## Disclaimer
Scripts are freely provided. They are not supported products of
Pointwise, Inc. Some scripts have been written and contributed by third
parties outside of Pointwise's control.

TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, POINTWISE DISCLAIMS
ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, WITH REGARD TO THESE SCRIPTS. TO THE MAXIMUM EXTENT PERMITTED
BY APPLICABLE LAW, IN NO EVENT SHALL POINTWISE BE LIABLE TO ANY PARTY
FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES
WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS
INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE USE OF OR
INABILITY TO USE THESE SCRIPTS EVEN IF POINTWISE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES AND REGARDLESS OF THE FAULT OR NEGLIGENCE OF
POINTWISE.
