% pipeline_duration_place_concatenation.m
% Sarah West 
% 6/12/23

%% Initial setup
% Put all needed paramters in a structure called "parameters", which you
% can then easily feed into your functions. 
clear all; 

% Output Directories

% Create the experiment name. This is used to name the output folder. 
parameters.experiment_name='Random Motorized Treadmill';

% Output directory name bases
parameters.dir_base='Y:\Sarah\Analysis\Experiments\';
parameters.dir_exper=[parameters.dir_base parameters.experiment_name '\']; 

% *********************************************************

% (DON'T EDIT). Load the "mice_all" variable you've created with "create_mice_all.m"
load([parameters.dir_exper 'mice_all.mat']);

% Add mice_all to parameters structure.
parameters.mice_all = mice_all; 

% ****Change here if there are specific mice, days, and/or stacks you want to work with****
parameters.mice_all = parameters.mice_all;
% 

% Give the number of digits that should be included in each stack number.
parameters.digitNumber=2; 

parameters.loop_variables.periods = {'rest', 'walk'}; % spontaneous continued periods 
parameters.loop_variables.mice_all = parameters.mice_all;
parameters.loop_variables.conditions =   {'motorized'; 'spontaneous'};

%% Motorized 

% Always clear loop list first. 
if isfield(parameters, 'loop_list')
parameters = rmfield(parameters,'loop_list');
end

% Iterators
parameters.loop_list.iterators = {'mouse', {'loop_variables.mice_all(:).name'}, 'mouse_iterator'; 
               'day', {'loop_variables.mice_all(', 'mouse_iterator', ').days(:).name'}, 'day_iterator';
               'stack', {'loop_variables.mice_all(',  'mouse_iterator', ').days(', 'day_iterator', ').stacks'}, 'stack_iterator'};

parameters.concatenation_level = 'day';
parameters.concatDim = 1;
parameters.concatenate_across_cells = false;

% Inputs
parameters.loop_list.things_to_load.data.dir = {[parameters.dir_exper 'behavior\motorized\period instances table format\'], 'mouse', '\', 'day', '\'};
parameters.loop_list.things_to_load.data.filename= {'all_periods_', 'stack', '.mat'};
parameters.loop_list.things_to_load.data.variable= {'all_periods.duration_place'}; 
parameters.loop_list.things_to_load.data.level = 'stack';

% Outputs
parameters.loop_list.things_to_save.concatenated_data.dir = {[parameters.dir_exper 'behavior\duration place concatenated\motorized\'], 'mouse', '\'};
parameters.loop_list.things_to_save.concatenated_data.filename= {'all_duration_place.mat'};
parameters.loop_list.things_to_save.concatenated_data.variable= {'all_duration_place'}; 
parameters.loop_list.things_to_save.concatenated_data.level = 'mouse';

RunAnalysis({@ConcatenateData}, parameters);

%% Spontaneous 
% Always clear loop list first. 
if isfield(parameters, 'loop_list')
parameters = rmfield(parameters,'loop_list');
end

% Iterators
parameters.loop_list.iterators = {'mouse', {'loop_variables.mice_all(:).name'}, 'mouse_iterator'; 
               'period', {'loop_variables.periods'}, 'period_iterator';
               'day', {'loop_variables.mice_all(', 'mouse_iterator', ').days(:).name'}, 'day_iterator';
               'stack', {'loop_variables.mice_all(',  'mouse_iterator', ').days(', 'day_iterator', ').spontaneous'}, 'stack_iterator';
               };

parameters.concatenation_level = 'day';
parameters.concatDim = 1;
parameters.concatenate_across_cells = false;

% Inputs
parameters.loop_list.things_to_load.data.dir = {[parameters.dir_exper 'behavior\spontaneous\segmented behavior periods\'], 'mouse', '\', 'day', '\'};
parameters.loop_list.things_to_load.data.filename= {'duration_places_', 'stack', '.mat'};
parameters.loop_list.things_to_load.data.variable= {'duration_places.', 'period'}; 
parameters.loop_list.things_to_load.data.level = 'stack';

% Outputs
parameters.loop_list.things_to_save.concatenated_data.dir = {[parameters.dir_exper 'behavior\duration place concatenated\spontaneous\'], 'mouse', '\'};
parameters.loop_list.things_to_save.concatenated_data.filename= {'all_duration_place_', 'period', '.mat'};
parameters.loop_list.things_to_save.concatenated_data.variable= {'all_duration_place'}; 
parameters.loop_list.things_to_save.concatenated_data.level = 'period';

RunAnalysis({@ConcatenateData}, parameters);

%% Convert spontaneous into cell form 
% with empty placeholder cells for the other 4 periods

% Always clear loop list first. 
if isfield(parameters, 'loop_list')
parameters = rmfield(parameters,'loop_list');
end

% Iterators
parameters.loop_list.iterators = {'mouse', {'loop_variables.mice_all(:).name'}, 'mouse_iterator'; 
               };

parameters.evaluation_instructions = {{'holder = [{parameters.rest} ; {parameters.walk}];' ...
                                        'data_evaluated = [holder; cell(4, 1)];'}};
        
% Inputs
% rest
parameters.loop_list.things_to_load.rest.dir = {[parameters.dir_exper 'behavior\duration place concatenated\spontaneous\'], 'mouse', '\'};
parameters.loop_list.things_to_load.rest.filename= {'all_duration_place_rest.mat'};
parameters.loop_list.things_to_load.rest.variable= {'all_duration_place'}; 
parameters.loop_list.things_to_load.rest.level = 'mouse';
% walk
parameters.loop_list.things_to_load.walk.dir = {[parameters.dir_exper 'behavior\duration place concatenated\spontaneous\'], 'mouse', '\'};
parameters.loop_list.things_to_load.walk.filename= {'all_duration_place_walk.mat'};
parameters.loop_list.things_to_load.walk.variable= {'all_duration_place'}; 
parameters.loop_list.things_to_load.walk.level = 'mouse';

% Outputs
parameters.loop_list.things_to_save.data_evaluated.dir = {[parameters.dir_exper 'behavior\duration place concatenated\spontaneous\'], 'mouse', '\'};
parameters.loop_list.things_to_save.data_evaluated.filename= {'all_duration_place.mat'};
parameters.loop_list.things_to_save.data_evaluated.variable= {'all_duration_place'}; 
parameters.loop_list.things_to_save.data_evaluated.level = 'mouse';

RunAnalysis({@EvaluateOnData}, parameters);


%% Put both conditions together in same cell array 

% Always clear loop list first. 
if isfield(parameters, 'loop_list')
parameters = rmfield(parameters,'loop_list');
end

parameters.loop_list.iterators = {'mouse', {'loop_variables.mice_all(:).name'}, 'mouse_iterator'; 
               'condition', 'loop_variables.conditions', 'condition_iterator';
                };

parameters.concatenation_level = 'condition';
parameters.concatDim = 1;
parameters.concatenate_across_cells = true;

% Inputs
parameters.loop_list.things_to_load.data.dir = {[parameters.dir_exper 'behavior\duration place concatenated\'], '\', 'condition', '\', 'mouse', '\'};
parameters.loop_list.things_to_load.data.filename= {'all_duration_place.mat'};
parameters.loop_list.things_to_load.data.variable= {'all_duration_place'}; 
parameters.loop_list.things_to_load.data.level = 'condition';

% Outputs
parameters.loop_list.things_to_save.concatenated_data.dir = {[parameters.dir_exper 'behavior\duration place concatenated\both conditions\'], 'mouse', '\'};
parameters.loop_list.things_to_save.concatenated_data.filename= {'all_duration_place.mat'};
parameters.loop_list.things_to_save.concatenated_data.variable= {'all_duration_place'}; 
parameters.loop_list.things_to_save.concatenated_data.level = 'mouse';

RunAnalysis({@ConcatenateData}, parameters);

parameters.concatenate_across_cells = false;