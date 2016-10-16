function varargout = gui(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)

if exist('features','var') && exist('labels','var') 
    set(handles.lblFeaturesStatus, 'String', 'Dataset loaded');   
else
    set(handles.lblFeaturesStatus, 'String', 'Dataset is not loaded');  
end

handles.N = str2double(get(handles.txtCount,'String'));
set(handles.table, 'data', zeros(handles.N,1));
set(handles.table, 'ColumnEditable', true);

fTypes = {'colorHistogram' 'edgeHistogram' 'colorAutoCorrelogram' 'colorMoments' 'coocMatrix'};
handles.fTypes = fTypes;

handles.selTypeInds = 1:length(fTypes);
set(handles.lstFeatures, 'Value', handles.selTypeInds);
set(handles.lstFeatures, 'String', handles.fTypes);
 
set(handles.scrHor, 'Visible', 'off');

handles.distType = 'cityblock';
handles.dataset = '1000';

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnLoadFeatures.
function btnLoadFeatures_Callback(hObject, eventdata, handles)

if exist([handles.dataset '.mat'],'file') > 0
    load(handles.dataset);
    set(handles.lblFeaturesStatus, 'String', 'Dataset loaded'); 
    handles.features = features;
    handles.labels = labels;

    guidata(hObject, handles);
else
    set(handles.lblFeaturesStatus, 'String', 'Dataset is not loaded');   
end
    

% --- Executes on button press in btnCreateFeatures.
function btnCreateFeatures_Callback(hObject, eventdata, handles)

[features, labels] = prepareDataset(['images' handles.dataset], handles.fTypes); 

set(handles.lblFeaturesStatus, 'String', 'Dataset loaded'); 

handles.features = features;
handles.labels = labels;
beep;
guidata(hObject, handles);


% --- Executes on button press in btnSaveFeatures.
function btnSaveFeatures_Callback(hObject, eventdata, handles)

features = handles.features;
labels = handles.labels;

if exist('features','var') && exist('labels','var')  
    save(handles.dataset, 'features','labels');
    helpdlg('Features have been saved successfuly!');
else
    errordlg('There are no features to save!');
end

function txtCount_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of txtCount as text
%        str2double(get(hObject,'String')) returns contents of txtCount as a double

handles.N = str2double(get(handles.txtCount,'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function txtCount_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnLoadImage.
function btnLoadImage_Callback(hObject, eventdata, handles)

[fname, pthname] = uigetfile(['images' handles.dataset '/*.jpg'], 'Select the query image');
if (fname ~= 0)
    handles.imgPath = strcat(pthname, fname);
    slashInds = strfind(pthname,filesep);
    
    handles.imgLabel = str2double(pthname(slashInds(end-1)+1:slashInds(end)-1));
    guidata(hObject, handles);
end


% --- Executes on button press in btnQuery.
function btnQuery_Callback(hObject, eventdata, handles)

performQuery(hObject, handles, true);


% Performs the image query
function performQuery(hObject, handles, rstWeights)

if isfield(handles, 'imgPath') 
    
    if rstWeights
        handles.features = resetWeights(handles.features, handles.selTypeInds);
    end
    
    features = handles.features;
    labels = handles.labels;
    
    if rstWeights
        f = extractFeatures(handles.imgPath, handles.fTypes, features(:,3));
        handles.f = f;
    else
        f = handles.f;
    end
    
    N = handles.N;
    set(handles.table,'data', zeros(N,1));
    
    inds = getClosestImages(features, f, N, handles.distType, handles.selTypeInds);
    
    yCnt = 2;
    xCnt = ceil(N/2);
    
    plotWidth = 120*xCnt;
    
    % Set the size of the inner panel to the full plot size so that it can be scrolled inside the outer panel
    set(handles.pnlInner, 'Position', [0 0 plotWidth 350]);
    
    % Display the images returned by the query
    axes('Unit', 'pixels', 'Parent', handles.pnlInner);
    
    for i = 1:N
        % Compute the index in the subplot that will result in the desired layout
        tInd = ceil(i/2);
        if mod(i,2) == 0;
            tInd = tInd + ceil(N/2);
        end
        
        imgPath = labels{inds(i),2};
        I = imread(imgPath);
        subtightplot(yCnt, xCnt, tInd);
        imshow(I, []);
        title(num2str(i));
    end
      
    % Compute the precision 
    precision = 0;
    for i = 1:N
        if labels{inds(i),1} == handles.imgLabel
            precision = precision + 1;
        end
    end

    precision = precision / N;
    set(handles.lblPrecision, 'String', num2str(precision));
    
    % Generate the feedback automatically
    feedback = generateFeedback(labels, inds, handles.imgLabel, N);
    
    set(handles.table,'data',feedback);
    

    set(handles.scrHor, 'Visible', 'on');
    set(handles.scrHor, 'Value', 0);
    
    guidata(hObject, handles);
else
    errordlg('No image is loaded');
end


% --- Executes on button press in btnUpdateResults.
function btnUpdateResults_Callback(hObject, eventdata, handles)

feedback = get(handles.table, 'data');
handles.features = updateWeights(handles.features, handles.f, feedback, handles.N, handles.distType, handles.selTypeInds);

performQuery(hObject, handles, false);


% --- Executes on button press in btnTestPerformance.
function btnTestPerformance_Callback(hObject, eventdata, handles)

if isfield(handles, 'features')  && isfield(handles, 'labels')  
    
    disp('Measuring performance...');
    feedbackCnt = str2double(get(handles.txtFeedbackCount,'String'));
    tic;
    results = testPerformance(handles.features, handles.labels, handles.N, handles.distType, handles.selTypeInds, feedbackCnt);
    elapsedTime = toc;
    disp(results);
    
    [MAP, MAR] = wMean(results);
    fprintf('Mean precision : %.2f. Mean recall: %.2f. Elapsed time : %.2f\n', MAP, MAR, elapsedTime);
    beep;
    guidata(hObject, handles);
else
    errordlg('No dataset is loaded!');
end


% --- Executes on slider movement.
function scrHor_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

outerPnlPos = get(handles.pnlOuter, 'Position');
innerPnlPos = get(handles.pnlInner, 'Position');

maxOffset = innerPnlPos(3) - outerPnlPos(3);

if maxOffset < 0
    maxOffset = 0;
end

scrPos = get(hObject,'Value');

innerPnlPos(1) = -scrPos * maxOffset;

set(handles.pnlInner, 'Position', innerPnlPos);


% --- Executes on selection change in cmbDistMetric.
function cmbDistMetric_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns cmbDistMetric contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cmbDistMetric

cmbContents = cellstr(get(hObject,'String'));
handles.distType = cmbContents{get(hObject,'Value')};

guidata(hObject, handles);

% --- Executes on selection change in lstFeatures.
function lstFeatures_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns lstFeatures contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lstFeatures

handles.selTypeInds = get(hObject,'Value');

guidata(hObject, handles);


% --- Executes on selection change in cmbDataset.
function cmbDataset_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns cmbDataset contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cmbDataset

contents = cellstr(get(hObject,'String'));
handles.dataset = contents{get(hObject,'Value')};

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function scrHor_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function cmbDistMetric_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function txtFeedbackCount_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function lstFeatures_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lstFeatures (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function cmbDataset_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function [MAP, MAR] = wMean(a)
 MAP = sum(a(:,1) .* a(:,3)) / sum(a(:,3));
 MAR = sum(a(:,2) .* a(:,3)) / sum(a(:,3));
