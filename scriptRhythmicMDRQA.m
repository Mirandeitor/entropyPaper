%This script is going to process the rhytmic data and perform
%multidimensional RQA on limbs data

%V 1.0 Creation of the document by David Lopez Perez 01.12.2021


%% Load and reduction of the data to the limbs of interest

%Select the parent folder where all the subfolders with the sensor data are
%located
clear all;
parent_directory = uigetdir;
files = dir(parent_directory);
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];
% Extract only those that are directories.
subFolders = files(dirFlags);
%Get the names of the folder names and a reduce the number of position for
%further analyses
folderNames = {subFolders.name};
subFolders = subFolders(~ismember(folderNames ,{'.','..','.DS_Store'}));
folderNames = folderNames(~ismember(folderNames ,{'.','..','.DS_Store'}));

%Load the conversion file
for iSub = 1:length(subFolders)
    filesInFolder = dir(strcat(parent_directory,'/',subFolders(iSub,1).name));
    fileNames = {filesInFolder.name};
    filesInFolder = filesInFolder(~ismember(fileNames ,{'.','..','.DS_Store'}));
    for iFile=1:length(filesInFolder)
        data{iSub,iFile} = importdata(strcat(parent_directory,'/',subFolders(iSub).name,'/',filesInFolder(iFile,1).name));
        positions = strfind(filesInFolder(iFile,1).name,'_');
        device{iSub,iFile}  = filesInFolder(iFile,1).name(positions(end)+1:positions(end)+8);
    end
end
%Load the conversion of body parts 
[codes,bodyParts] =  loadCodes_BodyParts(device(1,:))

%Load the body parts to see which one we are gonna use to reduce the data
[values,ok] = listSelectionDialog(bodyParts, {} , 'Select the parts for interest for the analysis' );
listOfSelectedParts = values';
%match the selected parts into
for iSelected = 1:size(listOfSelectedParts,2)
    for iPart = 1:size(bodyParts,2)
        if strcmp(listOfSelectedParts{1,iSelected},bodyParts{1,iPart})
            bodyPartsNumber(iSelected) = iPart;
            break;
        end
    end
end

% Remove the unnecesary data for further processing
device = device(:,bodyPartsNumber);
data = data(:,bodyPartsNumber);

%% Pre-process all the data and generate the average movement signals

% The data is sorted alfabetically -> Firstcolumn Infant Left Arm; Second
% Column Infant Right Arm, Third column is the ParentLeftHand and the last
% column is the ParentRightHand
positions = {};
for iSub = 1:length(subFolders)
    %For each infant we calculate the position of this data to avoid
    %differences in the way the data was exported.    
    for iColumn=1:size(data{iSub,1}.textdata,2)
        switch data{iSub,1}.textdata{end,iColumn}
            case 'Acc_X'              
                [positions(iSub).acceleration] = iColumn-2:1:iColumn;
            case 'Gyr_X'
                [positions(iSub).gyroscope] = iColumn-2:1:iColumn;
            case 'Mag_X'            
                [positions(iSub).magneticField] = iColumn-2:1:iColumn;
        end
    end
    %Remove the structure so can perform the interpolation easier
    for iFile=1:size(data,2)
        dataAux{1,iFile} = data{iSub,iFile}.data;
    end    
    data(iSub,:) = dataAux;

    %% Filter and Interpolate the data %% 
    [frequency(iSub), dataFiltered] = filterSensorData(data(iSub,:),strcat(path,strcat(parent_directory,'/',subFolders(iSub).name,'/',filesInFolder(1,1).name)));    
    dataFiltered_Interpolate(iSub,:) = dataFiltered;
    
end

%Select the plot you want to perform and if you want to compare accelerate
%and quaternion based measures.
[compareAll,movement1D,quaternionDistances] = loadSensorProcessingOptions();

%%Calculate the sensorMovement based on the selected options and
%%filteredData
for iVisit = 1:length(dataFiltered_Interpolate)
    displacement(iVisit,:) = estimateSensorDisplacement(dataFiltered_Interpolate(iVisit,:),compareAll,movement1D,quaternionDistances,frequency(iVisit),positions(iVisit));
end

%If there is previous data upload to process the new files (in case new
%parameters can be reused
%previousMdRQA = inpudlg('Do you wanna load previous data to update the sample (y/n)');
%if strcmp(previousMdRQA{1},'y')
%else
%end


%Estimate the RQA embedded and delay measures

previousDelay = inputdlg('Do you wanna load previous delay for the analysis (y/n)');
if strcmp(previousDelay{1},'n')
    for iVisit = 1:length(displacement) 
        %{
        for iSensor = 1:size(displacement,2)        
            [inf,s] = mi(displacement{iVisit,iSensor},40,100);%
            delay(iVisit,iSensor) =  round(inf(1,1));       
        end 
        %}
        %Multidimensional parameters estimation
        for iSensor = 1:min(size(displacement))
            DATA(iSensor,:) = displacement{iVisit,iSensor};
        end        
        delay(iVisit) = mdDelay(DATA','maxLag',20,'plottype', 'none');
        clear DATA
    end
    delay = round(delay);
    if delay == 0
        delay = 1;
    end
else
    manualDelay = inputdlg('Select the delay');
    delay = str2num(manualDelay{1});
end


%Estimate the delay
%Estimate the embedded dimension
previousEmb = inputdlg('Do you wanna load previous delay for the analysis (y/n)');
if strcmp(previousEmb{1},'n')
    for iVisit = 1:length(displacement)    
        %{
        for iSensor = 1:size(displacement,2) 
            dim = fnn(displacement{iVisit,iSensor},20,round(mean2(delay)),5);%Dimension estimation
            [~,idx(iVisit,iSensor)] = min(dim);   
        end
        %}
        %Multidimensional parameters estimation
        for iSensor = 1:min(size(displacement))
            DATA(iSensor,:) = displacement{iVisit,iSensor};
        end        
        [percentage, embedding] = mdFnn(DATA',1,'maxEmb',20,'doPlot', 0);
        
        embTemporal = embedding(percentage==min(percentage));
        if length(embTemporal)>1
            emb(iVisit) = embTemporal(1);
        else
            emb(iVisit) = embTemporal;
        end
        clear DATA embedding percentage
    end
    idx = round(mean(emb));
    if emb == 0
        idx = 1;
    end
else
    manualEmb = inputdlg('Select the dimension');
    idx = str2num(manualEmb{1});
end

%Find the list of codes with the first visit to establish the radio
for iFolder = 1:length(folderNames)
    positionsUnderscore = strfind(folderNames{iFolder},'_');
    babyCode{iFolder} = folderNames{iFolder}(1:positionsUnderscore-1);
    babyVisit(iFolder) = folderNames{iFolder}(end);
end
%Find the unique list of codes
listBabies = unique(babyCode);
valuesToPerformAnalysis = zeros([1 length(folderNames)]);
for iBaby=1:length(listBabies)
    %Find the minimum
    firstVisitCode = char(min(babyVisit(startsWith(folderNames,listBabies{iBaby}))));
    babyToFind = strcat(listBabies{iBaby},'_',firstVisitCode);
    valuesToPerformAnalysis = valuesToPerformAnalysis | strcmp(folderNames,babyToFind);
end

%% Run MdRQA
for iVisit = 1:length(displacement)
    if valuesToPerformAnalysis(iVisit)
        %Prepare the time series
        rec = 0;
        RAD = 0.2;
        DATA = zeros([length(displacement{iVisit}) size(displacement,2)]);
        for iFile = 1:size(displacement,2)
            %auxiliar = displacement{iVisit,iFile}';
            %DATA(:,iFile) = auxiliar(randperm(length(auxiliar)));
            DATA(:,iFile) = displacement{iVisit,iFile}';
            clear auxiliar
        end
        %% MdRQA of Four limbs
        while ((rec < 4.9) || (rec > 5.1))
            [RP, RESULTS, PARAMETERS, b]=mdrqa(DATA,round(mean2(idx)),round(mean2(delay)),'euc',RAD,1);
            rec = RESULTS(2);
            if rec < 4.9
                RAD = RAD + .1*RAD
            elseif rec > 5.1
                RAD = RAD - .1*RAD
            end        
        end
        ResultsMdRQA{iVisit} = RESULTS;
        ParametersMdRQA{iVisit} = PARAMETERS;
        RPMdRQA{iVisit} = RP;
        BMdRQA{iVisit} = b;
        clear DATA
    end
end

%Based on the extracted radius calculate the other time points
positionsOfRadius = find(valuesToPerformAnalysis);
for iBaby = positionsOfRadius
    babiesToAnalyse = strcmp(babyCode,babyCode{iBaby});
    %Obtain the information
    positionFirstVisit = intersect(positionsOfRadius,find(babiesToAnalyse));
    radius = ParametersMdRQA{positionFirstVisit}{4};    
    %Send that value to zero in babiesToAnalyse to avoid processing things
    %twice...comment this if you are running a random process.
    %babiesToAnalyse(positionFirstVisit) = 0;
    %Loop throw those values and save it in the final array.
    positionsToAnalyse = find(babiesToAnalyse);
    for iVisit = positionsToAnalyse
        for iFile = 1:size(displacement,2)
            %auxiliar = displacement{iVisit,iFile}';
            %DATA(:,iFile) = auxiliar(randperm(length(auxiliar)));
            DATA(:,iFile) = displacement{iVisit,iFile}';
        end
        [RP, RESULTS, PARAMETERS, b]=mdrqa(DATA,round(mean2(idx)),round(mean2(delay)),'euc',radius,1);
        ResultsMdRQA{iVisit} = RESULTS;
        ParametersMdRQA{iVisit} = PARAMETERS;
        RPMdRQA{iVisit} = RP;
        BMdRQA{iVisit} = b;
        clear DATA
    end    
end

%Save the radius to reuse in a different analysis in case we need to
%increase the sample

%Export the data in a xlsx file

%Visit goes from 1 to 4 max
recurrenceExport = [];
determinismExport = [];
entropyExport = [];
meanLineExport = [];

for iBaby = 1:length(positionsOfRadius)
    firstVisitCode = str2num(char(min(babyVisit(startsWith(folderNames,listBabies{iBaby})))));
    recurrenceExport(iBaby,firstVisitCode) = ResultsMdRQA{positionsOfRadius(iBaby)}(2);
    determinismExport(iBaby,firstVisitCode) = ResultsMdRQA{positionsOfRadius(iBaby)}(3);
    entropyExport(iBaby,firstVisitCode) = ResultsMdRQA{positionsOfRadius(iBaby)}(6);
    meanLineExport(iBaby,firstVisitCode) = ResultsMdRQA{positionsOfRadius(iBaby)}(4);
    if iBaby < length(positionsOfRadius) 
        newBaby = positionsOfRadius(iBaby)+1;
        while newBaby < positionsOfRadius(iBaby+1)            
            firstVisitCode = firstVisitCode+1;
            recurrenceExport(iBaby,firstVisitCode) = ResultsMdRQA{newBaby}(2);
            determinismExport(iBaby,firstVisitCode) = ResultsMdRQA{newBaby}(3);
            entropyExport(iBaby,firstVisitCode) = ResultsMdRQA{newBaby}(6);
            meanLineExport(iBaby,firstVisitCode) = ResultsMdRQA{newBaby}(4);
            newBaby = newBaby + 1;
        end
    else
        newBaby = positionsOfRadius(iBaby)+1;
        while newBaby <= length(ResultsMdRQA)            
            firstVisitCode = firstVisitCode+1;
            recurrenceExport(iBaby,firstVisitCode) = ResultsMdRQA{newBaby}(2);
            determinismExport(iBaby,firstVisitCode) = ResultsMdRQA{newBaby}(3);
            entropyExport(iBaby,firstVisitCode) = ResultsMdRQA{newBaby}(6);
            meanLineExport(iBaby,firstVisitCode) = ResultsMdRQA{newBaby}(4);
            newBaby =newBaby + 1;
        end
    end
end