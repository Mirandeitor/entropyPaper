# entropyPaper

Here we can find the scripts used for the analysis of mutidimensional motor data for the paper "Changes in the complexity of limbs movements during the first year of life across different tasks"


# Data
The data that support the findings will be available upon request from the corresponding authors following an embargo from the date of publication to allow for finalization of the ongoing longitudinal project. 

# Scripts

**Main Script**

- scriptRhytmicMDRQA.m -> controls the whole process of analysis. The script loads the data from one of the tasks and processes the data using multidimensional RQA on the time series of interest. Particularly: \
      * First select all the infant codes and visits from a parent folder where all the subfolders with the sensor data are located. \
      * Loads a conversion file which main goal is to convert the sensor internal codes to body parts of interest.\
      * Prompt a gui to select which parts are of interest for the analysis and remove unimportant data to save some memory.\
      * Pre-process the data by filtering and interpolating missing data.\
      * Then the movement time series are generated by calculating the quaternions or by obtaining the magnitude of the acceleration. \
      * Then the whole MdRQA analysis happen by first estimating the delay and embedding (those values can be added manually to save time if they have been previously calculated) and second for each baby we find the first visit and calculate the radius that allow for a 5% RR. Then those radiuses are later used for the calculate of the dynamics in the next visits.

**Multidimensional Analysis**

- mdrqa.m -> calculate the multidimensional RQA properties.
- mdFnn.m -> estimates de embedding dimension of a multidimensional time series.
- mdDelay.m -> estimates de delay of a multidimensional time series.

**Snipplets**

Here there a series of functions that are called from the main script:

- loadCodes_BodyParts.m -> load the codes and bodyparts from the codingFile (contains body parts to sensor codes conversion) to limit the analysis to certain body parts. 
- filterSensorData.m -> loads the data and return the interpolated and filtered data.
- interpolateSensorData.m -> this function interpolates the data from the sensor data to remove missing values. Initially a spline inteporlation is done, but in the future further expansions can be developed. 
- prepareDataForInterpolation.m -> this function takes an input array and return the data ready for interpolation with the missing values exactly in the place that it should be. 
- loadSensorProcessingOptions.m -> this function asks the user which kind of data will be analysed (quaternions or acceleration).
- estimateSensorDisplacement.m ->  estimate the movement (acc or quaternions) based on the sensor filtered data and options previously asked to the user.

# Citations

If you ever use parts of this code for your analysis please cite:

- Laudańska, Z.; López Pérez,D.; Radkowska, A.; Babis, K.,Malinowska-Korczak; A., Wallot, S.;Tomalski, P. (2022). Changes in the complexity of limbs movements during the first year of life across different tasks. _In Review_.

For the MdRQA part

- Wallot, S., Roepstorff, A., & Mønster, D. (2016). Multidimensional Recurrence Quantification Analysis (MdRQA) for the Analysis of Multidimensional Time-Series: A Software Implementation in MATLAB and Its Application to Group-Level Data in Joint Action. Frontiers in Psychology, 7. https://doi.org/10.3389/fpsyg.2016.01835 

- Wallot, S., & Mønster, D. (2018). Calculation of average mutual information (ami) and false-nearest neighbors (fnn) for the estimation of embedding parameters of multidimensional time series in Matlab. Frontiers in psychology, 9, 1679.

# Contact info
Any problem, question or missing functions please contact d.lopez@psych.pan.pl
