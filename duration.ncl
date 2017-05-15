load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

 path="/scratch/users/tballard/hw.index.duration.nc"
 f=addfile(path, "r")
 duration=f->hw_index_duration(:,:,::-1,:) ; lat must be in ascending order
 printVarSummary(duration)
 newgrid=g2fsh_Wrap(duration,(/2160,4320/))
 printVarSummary(newgrid)			
end
				