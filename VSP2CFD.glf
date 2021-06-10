#############################################################################
#
# (C) 2021 Cadence Design Systems, Inc. All rights reserved worldwide.
#
# This sample script is not supported by Cadence Design Systems, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#
#############################################################################

#
# ============================================================================
# GENERATE UNSTRUCTURED VOLUME MESH FOR OPENVSP GENERATED SURFACE MESH
# ============================================================================
# This script will import a surface mesh generated using OpenVSP and create
# an unstructured viscous mesh using T-Rex. The user has control over the 
# farfield size and boundary layer resolution. 
# 


#--------------------------------------------------------------
#-- INITIALIZATION
#--------------------------------------------------------------
package require PWI_Glyph
pw::Application reset
set cwd [file dirname [info script]]


#--------------------------------------------------------------
#-- USER DEFINED PARAMETERS
#--------------------------------------------------------------
# Geometry
set fileName         "VspAircraft.stl"; # OpenVSP STL filename
set farfieldDiameter 800;               # Farfield diameter (40x body length)

# Boundary Layer Paramters
set maxLayers        100;               # Maximum layers for boundary layer region
set initialDs        0.001;             # Initial cell height in the boundary layer
set growthRate       1.2;               # Growth rate in the boundary layer region
set boundaryDecay    0.95;              # Volumetric boundary decay
set farfieldSpacing  40;                # Farfield mesh spacing (2x body length)

# T-Rex Quality Criteria
set fullLayers       0;                 # Full layers (0 for multi-normals, 1 for single normal)
set collisionBuffer  2;                 # Collision buffer for colliding fronts
set maxAngle         170;               # Max included angle for boundary layer elements
set centroidSkew     1.0;               # Max centroid skew for boundary layer elements

 
#--------------------------------------------------------------
#-- MAIN
#--------------------------------------------------------------
# Import VSP File
puts ""
puts "Importing $fileName..."
puts ""

set vspDoms [pw::Grid import [file join $cwd $fileName]]

# Set connector dimension defaults
pw::Connector   setCalculateDimensionMethod  Spacing
pw::Connector   setCalculateDimensionSpacing $farfieldSpacing
pw::Application setGridPreference            Unstructured

# Find the center of the grid imported from VSP
set vspExtents [pw::Grid getExtents]

set minExtents [lindex $vspExtents 0]
set maxExtents [lindex $vspExtents 1]

set center(x) [expr {([lindex $minExtents 0]+[lindex $maxExtents 0])/2.0}]
set center(y) [expr {([lindex $minExtents 1]+[lindex $maxExtents 1])/2.0}]
set center(z) [expr {([lindex $minExtents 2]+[lindex $maxExtents 2])/2.0}]

# Create semicircular curve
puts ""
puts "Generating farfield domain..."
puts ""

set dbCurve [pw::Curve create]

    set seg [pw::SegmentCircle create]
        $seg addPoint       " [expr {($farfieldDiameter/2.0)+$center(x)}] $center(y) $center(z)"
        $seg addPoint       "-[expr {($farfieldDiameter/2.0)+$center(x)}] $center(y) $center(z)"
        $seg setCenterPoint "$center(x) $center(y) $center(z)"

$dbCurve addSegment $seg 

# Revolve curve to form a sphere for the farfield and create farfield domains
set sphere [pw::Surface create] 
    $sphere revolve -angle 360.0 $dbCurve "[expr {($farfieldDiameter/2.0)+$center(x)}] $center(y) $center(z)" "1 0 0"

set farfieldDoms [pw::DomainUnstructured createOnDatabase [list $sphere]]

# Assemble the block that consists of the VSP grid and the farfield
puts ""
puts "Assembling unstructured block..."
puts ""

set domList  [join [list $vspDoms $farfieldDoms]]
set unsBlock [pw::BlockUnstructured createFromDomains $domList]

# Setup unstructured block attributes
set solveMode [pw::Application begin UnstructuredSolver [list $unsBlock]] 

    $unsBlock setUnstructuredSolverAttribute TRexMaximumLayers            $maxLayers
    $unsBlock setUnstructuredSolverAttribute TRexFullLayers               $fullLayers 
    $unsBlock setUnstructuredSolverAttribute TRexGrowthRate               $growthRate 
    $unsBlock setUnstructuredSolverAttribute TRexCollisionBuffer          $collisionBuffer 
    $unsBlock setUnstructuredSolverAttribute TRexSkewCriteriaCentroid     $centroidSkew
    $unsBlock setUnstructuredSolverAttribute TRexSkewCriteriaMaximumAngle $maxAngle
    $unsBlock setUnstructuredSolverAttribute BoundaryDecay                $boundaryDecay

# Create and apply the boundary conditions for T-Rex
    set wallBC [pw::TRexCondition create]
        $wallBC setName "wall"
        $wallBC setType "Wall"
        $wallBC setSpacing $initialDs 

        foreach dom $vspDoms {
            $wallBC apply [list $unsBlock $dom]
        }

# Initialize the volume mesh
puts ""
puts "Initializing volume mesh..."
puts ""

$solveMode run Initialize
$solveMode end 

# Set CAE boundary conditions
puts ""
puts "Applying CAE boundary conditions..."
puts ""

set caeWallBC [pw::BoundaryCondition create]
    $caeWallBC setName "wall"
    foreach dom $vspDoms {$caeWallBC apply [list $unsBlock $dom]}

set caePatchBC [pw::BoundaryCondition create]
    $caePatchBC setName "farfield"
    foreach dom $farfieldDoms {$caePatchBC apply [list $unsBlock $dom]}

# Save Pointwise file
set fileRoot   [file rootname $fileName]
set fileExport "$fileRoot-Grid.pw"

puts ""
puts "Writing $fileExport file..."
puts ""

pw::Application save [file join $cwd $fileExport]

# Examine grid
puts "Grid Summary"
puts "------------------"
puts "[$unsBlock getCellCount] tet cells"
puts ""

# Maximum included angle examination
set blkExm [pw::Examine create BlockMaximumAngle]

    $blkExm addEntity $unsBlock
    $blkExm setRangeLimits 70.0 170.0
    $blkExm examine

    puts "[format "Maximum included angle: %.2f" [$blkExm getMaximum]]"
    puts "Number of cells above maximum (170): [$blkExm getAboveRange]"
    puts ""

$blkExm delete

# Centroid skew examination
set blkExm [pw::Examine create BlockSkewCentroid]

    $blkExm addEntity $unsBlock
    $blkExm setRangeLimits 0.0 0.7
    $blkExm examine

    puts "[format "Maximum centroid skew: %.2f" [$blkExm getMaximum]]"
    puts "Number of cells above maximum (0.7): [$blkExm getAboveRange]"
    puts ""

$blkExm delete


# END SCRIPT

#############################################################################
#
# This file is licensed under the Cadence Public License Version 1.0 (the
# "License"), a copy of which is found in the included file named "LICENSE",
# and is distributed "AS IS." TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE
# LAW, CADENCE DISCLAIMS ALL WARRANTIES AND IN NO EVENT SHALL BE LIABLE TO
# ANY PARTY FOR ANY DAMAGES ARISING OUT OF OR RELATING TO USE OF THIS FILE.
# Please see the License for the full text of applicable terms.
#
#############################################################################
