Order of operations February 17, 2023
# For processing glider AZFP data.

- Use Echoview to export ABC data from glider acoustics using a glider template. Currently being output at either 1mx1m or 5mx5m bins and uses a 10 degree filter. This data is exported as csv files from Echoview. 

- Use the SOCIB Matlab code to process the glider data. Currently this is provided as a mat file in 1mx1m bins(ie AMLR01BS2018_1M_BINS_FINAL.mat)

- Use the Matlab code entitled scr_load_glider_and_acoustic_data.m It calls f_merge_acoustic_abc.m and eview_2_matlab.m This code uses the SOCIB mat output and the multiple Echoview csv files. The code reads in the csv files by folder.
This process curently takes about 8 hours to complete for a 90 day deployment. Save the data as a .mat file. (ie AMLR01_2019_38khz_1mx1m_10deg.mat)

- Use the Matlab code entitled scr_merge_gridded_glider_and_acoustic_data.m. This process will merge the acoustic data and glider data together for the profile data, and exclude the surface data. 

- Use scr_glider_paper_figures_and_maps.m next. This uses remove_deep_data_spikes.m

