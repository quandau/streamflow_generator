#treamflow_Generator


Contents:

* `monsoonal_rescaling`: Directory containing Python code to rescale synthetic streamflows by changing the log-space mean, log-space standard deviation, and amplitudes and phase shifts of harmonics fit to the log-space annual cycle. Includes a README describing how to run the code. This method is used for the Red River basin in Vietnam in the following paper: Quinn, J.D., P.M. Reed, M. Giuliani, A. Castelletti, J.W. Oyler, R.E. Nicholas, 2018, "Exploring how changing monsoonal dynamics and human pressures challenge multi-reservoir management for flood protection, hydropower production and agricultural water supply", *Water Resources Research*, *54*, doi: [10.1029/2018WR022743](https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2018WR022743).

* `data`: Directory containing example data set for the Susquehanna River Basin (for a description of the system, see Giuliani, M., J.D. Herman, A. Castellett, P.M. Reed, 2014, "Many-objective reservoir policy identification and refinement to reduce policy inertia and myopia in water management", *Water Resources Research*, *50*, doi: [10.1002/ 2013WR014700](http://onlinelibrary.wiley.com/doi/10.1002/2013WR014700/full)).

* `stationary_generator`: Directory containing MATLAB code to generate correlated synthetic daily streamflow time series at multiple sites assuming stationary hydrology. Includes a README describing how to run the code.

* `validation`: Directory containing Python code to validate performance of synthetic streamflow generator. Includes a README describing how to run the code.
