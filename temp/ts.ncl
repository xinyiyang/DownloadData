    ;*********************************************************
    load "/share/kkraid/yangx2/software/ncl_6.5/lib/ncarg/nclscripts/csm/gsn_code.ncl"
    load "/share/kkraid/yangx2/software/ncl_6.5/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
    load "/share/kkraid/yangx2/software/ncl_6.5/lib/ncarg/nclscripts/csm/contributed.ncl"
    load "/share/kkraid/yangx2/software/ncl_6.5/lib/ncarg/nclscripts/csm/shea_util.ncl"
    load "/share/kkraid/yangx2/software/ncl_6.5/lib/ncarg/nclscripts/csm/shapefile_utils.ncl"   ;yangx2
    ;*********************************************************
        ;begin
            ; parameters
                his_date_start = 198912 ;it starts from Dec
                his_date_end   = 202011

                latN           = 10
                latS           = -30
                lonW           = -90
                lonE           = -40
                ; deg is used to tune the range of longitude    
                deg            = 0
            ; files in     
                mpfilename="/glade/work/xinyang/program/Amazon/mapdata/amazon_sensulatissimo_gmm_v1.shp"  

                dir_precip_1 = "/share/kkraid/yangx2/program/Amazon/data/full_data_monthly_v2022_1891-2020.AB.only.nc"
                ;unit is mm/month
                dir_precip_2 = "/share/kkraid/yangx2/program/Amazon/data/gpcp_v02r03_monthly_1979-2021.AB.only.nc"
                ;unit is mm/day

                ; observation
                fob         = addfile(dir_precip_1,"r")
                p_ob_t      = fob->precip    ; unit:mm/month
                p_ob        = p_ob_t
                p_ob@long_name= ""
                p_ob@units  = "mm/day"
                p_ob        = p_ob_t/30        ; unit mm/d
                ptime_ob    = p_ob_t&time
                optime_std  = cd_calendar(ptime_ob, -1)
                stbn1_op    = ind(optime_std.eq.his_date_start) 
                stbn2_op    = ind(optime_std.eq.his_date_end) 
                p_shift_ob     = p_ob(stbn1_op:stbn2_op,{latS:latN},{lonW:lonE})

                ; climatology
                p_ab =wgt_areaave_Wrap(p_shift_ob,1,1,1)
                ; rm annual cycle
                p_shift_ob_anom = rmMonAnnCycTLL(p_shift_ob)
                p_ab_anom=wgt_areaave_Wrap(p_shift_ob_anom, 1, 1, 1)

                ; monthly to yearly 
                nttimeob  = dimsizes(p_ab)
                p_ab_shift_tran = reshape(p_ab,(/nttimeob/12,12/))
                p_ab_shift_tran!0          = "year"
                p_ab_shift_tran!1          = "mon"

                yeartime= ispan(1900,2020,1)
                p_ab_shift_tran&year       = yeartime
                p_ab_shift_tran&mon        = (/1,2,3,4,5,6,7,8,9,10,11,12/)
                p_ab_shift_tran@long_name= ""
                p_ab_shift_tran@units= ""

                p_ab_shift_annual       = p_ab_shift_tran(:,0:11)
                pob_shift_annual _ts    = dim_avg_n_Wrap(p_ab_shift_annual, 1)

                ob_timespan      = ispan(0, dimsizes(pob_shift_annual _ts (:))-1, 1)
       

            print("Calculation done!")


            ; Plot
                wks     = gsn_open_wks("pdf","/share/kkraid/yangx2/program/Amazon/pics/precip_ts")             ; open a ps plot
                nplots  = 1                   ; for numbers of plots
                plot    = new(nplots,graphic)
                poly    = new(nplots,graphic)
                splot    = new(nplots,graphic)

                ; 2nd
                    res2                              = True               ; plot mods desired
                    res2@gsnDraw                      = False
                    res2@gsnFrame                     = False              ; don't advance frame yet     

                    res2@cnFillOn                     = True               ; turn on color for contours
                    res2@cnLinesOn                    = False              ; turn off contour lines
                    res2@cnLineLabelsOn               = False              ; turn off contour line labels
                    res2@cnInfoLabelOn                = False 
                    
                    ;  Shaded
                    ;res2@gsn_Add_Cyclic               = False
                    ;res2@cnFillPalette                = "temp_19lev"       ; set the color map
                    res2@cnFillPalette                = "precip3_16lev"       ; set the color map
                    res2@lbLabelStride                = 2 
                    res2@mpFillOn                     = True
                    res2@mpLandFillColor              = "white"            ; set land to be gray

                    ;res2@mpMinLonF                    = lonW+deg                 ; select a subregion
                    ;res2@mpMaxLonF                    = lonE-deg
                    res2@mpMinLatF                    = latS 
                    res2@mpMaxLatF                    = latN
                    res2@tmXBMinorOn                  = True
                    res2@mpCenterLonF                 = 180

                    res2@mpMinLonF                    = -120                 ; select a subregion
                    res2@mpMaxLonF                    = 0
                    res2@mpMinLatF                    = latS 
                    res2@mpMaxLatF                    = latN
                    res2@tmXBMinorOn                  = True
                    res2@mpCenterLonF                 = -60

                    ;res2@lbLabelBarOn                 = True               ; turn off individual cb's
                    res2@lbLabelBarOn                 = False               ; turn off individual cb's
                    res2@lbOrientation                = "Horizontal"       ; vertical label bar
                    res2@pmLabelBarOrthogonalPosF     = 0.08               ; move label bar closer

                    res2@cnLevelSelectionMode         = "ManualLevels"     ; set manual contour levels
                    res2@cnMinLevelValF               = 2               ; set min contour level
                    res2@cnMaxLevelValF               = 14                ; set max contour level
                    res2@cnLevelSpacingF              = 1                ; set contour spacing        
     
                    ; Title
                    res2@gsnLeftString                = "historical: 190001-201412 "
                    ;res2@gsnLeftStringOrthogonalPosF = -0.001
                    res2@gsnStringFontHeightF         = 0.017
                    res2@gsnRightString               = ""

                    ; adding Amazon outline
                      pres                   = True
                      pres@gsLineColor       = "red"
                      pres@gsLineDashPattern = 0
                      pres@gsLineThicknessF  = 2
                      
                do i = (r_start-1),(r_end-1)
                    res2@gsnLeftString                = model_name(i)
                    plot(i+1) = gsn_csm_contour_map_ce(wks,diff_p_mm(:,:,i),res2)

                    poly(i+1) = gsn_add_shapefile_polylines(wks,plot(i+1),mpfilename,pres)
                end do

                res2@gsnLeftString                = "Observation"
                plot(0) = gsn_csm_contour_map_ce(wks,p_ob_shift_Annual_mean,res2)
                poly(0) = gsn_add_shapefile_polylines(wks,plot(0),mpfilename,pres)

                ; create panel
                    resP                                = True                ; modify the panel plot
                    resP@gsnPanelFigureStrings          = (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)","(m)","(n)","(o)"/)           ; add strings to panel
                    resP@gsnPanelFigureStringsJust      = "TopLeft" 
                    resP@gsnPanelMainString             = "pr (unit: mm/d): Annual Mean (190001-201412)"
                    resP@gsnPanelLabelBar               = True                ; add common colorbar
                    resP@gsnPanelRowSpec                = True                   ; tell panel what order to plot
                    resP@gsnPanelCenter                 = False
                    resP@lbLabelFontHeightF             = 0.007               ; make labels smaller

                    gsn_panel(wks,plot,(/4,4,4,4/),resP)               ; now draw as one plot

                    print("plot done!")
            end 

