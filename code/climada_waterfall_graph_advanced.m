function climada_waterfall_graph_advanced(return_period, check_printplot, ELS1, ELS2, ELS3, ELS4, ELS5, ELS6)
% waterfall figure, expected loss for specified return period for 
% - today,
% - increase from economic growth, 
% - increase from high climate change, total expected loss 2030
% for the three ELS quoted above
% NAME:
%   climada_waterfall_graph
% PURPOSE:
%   plot expected loss for specific return period
% CALLING SEQUENCE:
%   climada_waterfall_graph(return_period,
%   check_printplot,ELS1, ELS2, ELS3,...)
% EXAMPLES:
%   climada_waterfall_graph
%   climada_waterfall_graph_INCL_RAIN4('AEL', 0, ELS_2012, ELS_2030, ELS_2030_clim, ELS_2012_rain, ELS_2030_rain, ELS_2030_clim_rain)
%   climada_waterfall_graph_INCL_RAIN4('AEL', 0, ELS_2012, ELS_2030, ELS_2030_clim)
% INPUTS:
%   none
% OPTIONAL INPUT PARAMETERS:
%   ELS PER HAZARD three event loss sets (order of ELS files does not play a role)
%                   - today
%                   - economic growth
%                   - cc combined with economic growth, future
%   return_period:  requested return period for according expected loss,or
%                   annual expted loss, prompted if not given
%   check_printplot:%   check_printplot:if set to 1, figure saved, default 0. 
%                           
% OUTPUTS:
%   waterfall graph
% MODIFICATION HISTORY:
% Lea Mueller, 20110622
% Martin Heynen, 20120307
% david.bresch@gmail.com, 20140804, GIT update
%-

global climada_global
if ~climada_init_vars, return; end

% check function inputs and assign the "input case":
%   - no_input-->prompt for files
%   - only wind ELS given
%   - wind and rain ELS given
%   - none of the above --> stopp, warning

if     ~exist('ELS1','var') && ~exist('ELS2','var') && ~exist('ELS3','var')...
       && ~exist('ELS4','var') && ~exist('ELS5','var') && ~exist('ELS6','var')
 
            case_='no_input';

            ELS1 = []; 
            ELS2 = []; 
            ELS3 = []; 
            ELS4 = []; 
            ELS5 = []; 
            ELS6 = []; 
 
elseif exist('ELS1','var') && exist('ELS2','var') && exist('ELS3','var')...
       && (~exist('ELS4','var') || isempty(ELS4)) && (~exist('ELS5','var')...
       || isempty(ELS5)) && (~exist('ELS6','var') || isempty(ELS5))
        
            case_='only_wind_ELS';
            
           
    
elseif  exist('ELS1','var') && exist('ELS2','var') && exist('ELS3','var')...
        && exist('ELS4','var') && exist('ELS5','var') && exist('ELS6','var')
 
            case_='wind_and_rain_ELS';
            
           
         
else   %no valid input
   warning('m_id','function stopped: please choose as function input 3 ELS structs or 6 ELS structs to include the ELS_rain, respectively or select the according files if no input is stated') 
   return;
end

if ~exist('return_period'  ,'var'), return_period   = []; end
if ~exist('check_printplot','var'), check_printplot = 0; end


%add stats and create ELS struct according to the "function input case"
switch case_
    case 'no_input'
        
        prompt   ='Do you want to include ELS from another hazard (e.g. rain)? (y=yes, n=no)';
        name     ='more than one hazard  ?';
        defaultanswer = {'y or n'};
        answer   = inputdlg(prompt, name, 1, defaultanswer);
        
        if strcmp(answer{1},'y') 
            nr_ELS_to_prompt=6;
        else
            nr_ELS_to_prompt=3;
        end
          
        % load EVENT LOSS SET 
        % prompt for ELS if not given
        % local GUI 
        % save filenames and pathnames
        ELS                  = [climada_global.data_dir filesep 'results' filesep '*.mat'];
        ELS_default          = [climada_global.data_dir filesep 'results' filesep ['select EXACTLY ', num2str(nr_ELS_to_prompt), ' ELS .mat']];
        [filename, pathname] = uigetfile(ELS, ['Select the ' , num2str(nr_ELS_to_prompt), '  ELS files:'],ELS_default,'MultiSelect','on');
        if isequal(filename,0) || isequal(pathname,0)
        warning('m_id2','function stopped: please choose as function input 3 ELS structs or 6 ELS structs to include the ELS_rain, respectively or select the according files if no input is stated') 
        return;
        end
        
        %load files with the above prompted fielnames, add stats and create ELS struct
        if iscell(filename)
            for i = 1:length(filename);
                %get var name
                %N:\SRZTIH\Sustainability\Climada\climada_small_NEU_9_4_2012\climada\data\results\ELS_2030_rain.mat
                load(fullfile(pathname,filename{i}))
                %save loaded file under ELS1
                ELS1 = eval(strtok(filename{i},'.'));
                %add statistics if not yet there
                if ~isfield(ELS1,'loss_sort')
                    ELS1 = climada_ELS_stats(ELS1, 0);
                end
                %temporarily save in ELS
                ELS_(i) = ELS1;
            end
        %rename to ELS
        ELS = ELS_;
        clear ELS_ 
        else
            load(fullfile(pathname,filename))
        end
    

        
        
      
    case {'only_wind_ELS','wind_and_rain_ELS'}
        ELS    = struct([]);
        %MH add stats to given input ELS
        % check if statistics are given, if not add statistics
        if ~isfield(ELS1,'loss_sort'),ELS1 = climada_ELS_stats(ELS1, 0);end
        if ~isfield(ELS2,'loss_sort'),ELS2 = climada_ELS_stats(ELS2, 0);end
        if ~isfield(ELS3,'loss_sort'),ELS3 = climada_ELS_stats(ELS3, 0);end
        
        ELS    = ELS1;
        ELS(2) = ELS2;
        ELS(3) = ELS3;
        
        if strcmp(case_,'wind_and_rain_ELS')
            if ~isfield(ELS4,'loss_sort'),ELS4 = climada_ELS_stats(ELS4, 0);end
            if ~isfield(ELS5,'loss_sort'),ELS5 = climada_ELS_stats(ELS5, 0);end
            if ~isfield(ELS6,'loss_sort'),ELS6 = climada_ELS_stats(ELS6, 0);end
            
            ELS(4) = ELS4;
            ELS(5) = ELS5;
            ELS(6) = ELS6;
        end
end %end switch


%sepparate ELS_TC and ELS_RAIN, ELS(1:3)-> wind, ELS(4:6)-> rain
%up to now ELS from rain have the field ELS.hazard.peril_ID='TC_rain'
if length(ELS)>3
    count1=0;
    count2=0;
    for ELS_i = 1:length(ELS)
        if strcmp(ELS(1,ELS_i).hazard.peril_ID,'TC_rain')
           count1=count1+1;
           ELS_rain(count1)=ELS(1,ELS_i);
        else
           count2=count2+1;
           ELS_wind(count2)=ELS(1,ELS_i);
         end
    end
    ELS    = struct([]);
    ELS=[ELS_wind, ELS_rain];
end    


%prompt for return period or annual expected loss (AEL)
if isempty(return_period)
    prompt   ='Choose specific return period or annual expected loss [e.g. 1, 10, 500, AEL]:';
    name     ='Return period or annual expected loss';
    defaultanswer = {'AEL or 1 or 50 etc'};
    answer   = inputdlg(prompt, name, 1, defaultanswer);
    if strcmp(answer{1},'AEL')
        return_period = 9999;
    else
        return_period = str2num(answer{1});
    end
elseif ischar(return_period)
    if strcmp(return_period,'AEL')
        return_period = 9999;
    else 
        fprintf('Please indicate return period (e.g. 1, 34, 50) or "AEL"\n "%s" does not exist\n',return_period)
        return
    end
end


 % check if annual expected loss is requested and if not find index for
 % requested return period save all losses under loss
for ELS_i = 1:length(ELS)
    if return_period == 9999
        loss(ELS_i) = ELS(ELS_i).EL;
    else
        r_index = ELS(1).R_fit == return_period;
        if sum(r_index)<1
            fprintf('\n--no information available for requested return period %i -- \n...--please select one of the following return periods:  --\n',int2str(return_period))
            disp(int2str(ELS(ELS_i).R_fit'))
            fprintf('\n')
            loss = [];
            return
        else
            loss(ELS_i) = ELS(ELS_i).loss_fit(r_index);
        end
    end
    % identification of ELS_i
    hazard_name       = strtok(ELS(ELS_i).hazard.comment,',');
    hazard_name       = horzcat(hazard_name, ' ', int2str(ELS(ELS_i).reference_year));
    [fP, assets_name] = fileparts(ELS(ELS_i).assets.filename);
    str               = sprintf('%s | %s',assets_name, hazard_name);
    str               = strrep(str,'_',' '); % since title is LaTEX format
    str               = strrep(str,'|','\otimes'); % LaTEX format
    legend_str{ELS_i} = str;       
end % ELS_i


%Sort loss to know which is the loss_today, loss_eco, loss_eco_cc
[loss_wind index1]      = sort(loss(1:3),'ascend');
if length(ELS)>3
    [loss_rain index2]      = sort(loss(4:6),'ascend'); 
    index2=index2+3;
end

%Sort strings for the legend
legend_str_1=legend_str(index1);
if length(ELS)>3
    legend_str_2=legend_str(index2);
    legend_str_new={legend_str_1(1), legend_str_1(2), legend_str_1(3),...
    legend_str_2(1),legend_str_2(2),legend_str_2(3)}
else
    legend_str_new={legend_str_1(1), legend_str_1(2), legend_str_1(3)}
    
end

%sum up wind and rain loss
if length(ELS)>3
    loss=[loss_wind + loss_rain]; 
else
    loss=loss_wind;
end


% gets digits of loss
digits = log10(max(loss));
digits = floor(digits)-1;
        loss = loss*10^-digits;
        loss_wind = loss_wind*10^-digits;
        if length(ELS)>3
        loss_rain = loss_rain*10^-digits;
        end
        dig  = digits;


if length(ELS)>3
loss_rain_difference = [loss_rain(1) loss_rain(2)-loss_rain(1) loss_rain(3)-loss_rain(2)]
end


%----------
%% figure
%----------

fig        = climada_figuresize(0.57,0.7);
color_     = [227 236 208;...   %hazard 1
              194 214 154;...   %hazard 1  
              181 205  133;...  %hazard 1 
              197 190 151;...   %hazard 1
              207 216 188;...   %hazard 2 
              174 194 134;...   %hazard 2   
              161 185  113;...  %hazard 2 
              177 170  131;...  %hazard 2
              120 120 120]/256; %dotted line
stretch    = 0.3; %width of bars
loss_count = length(loss)+1;

loss=[0 loss];
fontsize_=8;

hold on
%total loss wind
area([loss_count-stretch loss_count+stretch], loss(4)*ones(1,2),'facecolor',color_(4,:),'edgecolor','none')


% single losses wind
% area([loss_count-stretch loss_count+stretch], loss(8)*ones(1,2),'facecolor',[109 101 104]/255,'edgecolor','none')
for i = 1:5-2 %1:length(loss)-2
    h(i) = patch( [i-stretch i+stretch i+stretch i-stretch],...
                  [loss(i) loss(i) loss(i+1) loss(i+1)],...
                  color_(i,:),'edgecolor','none');
    if i==1
          plot([i+stretch 4+stretch],[loss(i+1) loss(i+1)],':','color',color_(9,:))
    else
          plot([i+stretch 4-stretch],[loss(i+1) loss(i+1)],':','color',color_(9,:))
    end
end

% add losses from rain
if length(ELS)>3
    %add total loss coming from rain
    patch( [4-stretch 4+stretch 4+stretch 4-stretch],...
                      [loss_wind(3) loss_wind(3) loss(4) loss(4)],...
                      color_(8,:),'edgecolor','none');

    %add single losses coming from rain 
    for i = 1:5-2 %1:length(loss)-2
        h(i+3) = patch( [i-stretch i+stretch i+stretch i-stretch],...
                      [loss(i+1)-loss_rain_difference(i) loss(i+1)-loss_rain_difference(i) loss(i+1) loss(i+1)],...
                      color_(i+4,:),'edgecolor','none');
         if i==1
          plot([i+stretch 4+stretch],[loss(i+1) loss(i+1)],':','color',color_(9,:))
        else
          plot([i+stretch 4-stretch],[loss(i+1) loss(i+1)],':','color',color_(9,:))
        end
    end
end

N = -abs(floor(log10(max(loss)))-1);
loss_disp(1) = round(  loss(2)          *10^N)/10^N;
loss_disp(2) = round( (loss(3)-loss(2)) *10^N)/10^N;
loss_disp(3) = round( (loss(4)-loss(3)) *10^N)/10^N;
loss_disp(4) = round(  loss(4)          *10^N)/10^N;


%losses above bars
text(1, loss(2)                      , int2str(loss_disp(1)), 'color','k', 'HorizontalAlignment','center', 'VerticalAlignment','bottom','FontWeight','bold','fontsize',fontsize_);
text(2, loss(2)   + (loss(3)-loss(2))/2, int2str(loss_disp(2)), 'color','w', 'HorizontalAlignment','center', 'VerticalAlignment','middle','FontWeight','bold','fontsize',fontsize_);
text(3, loss(3)   + (loss(4)-loss(3))/2, int2str(loss_disp(3)), 'color','w', 'HorizontalAlignment','center', 'VerticalAlignment','middle','FontWeight','bold','fontsize',fontsize_);
text(4, loss(4)                      , int2str(loss_disp(4)), 'color','k', 'HorizontalAlignment','center', 'VerticalAlignment','bottom','FontWeight','bold','fontsize',fontsize_);

%axis range and ylabel
xlim([0.5 4.5])
ylim([0   max(loss)*1.25])
ylabel(['Loss amount \cdot 10^', int2str(dig)],'fontsize',fontsize_)

%arrow 
climada_arrow  ([4 loss(2)], [4 loss(4)], 40, 10, 30,'width',1.5,'Length',10, 'BaseAngle',90, 'EdgeColor','none', 'FaceColor',[256 256 256]/256);
text   (4, loss(2)-max(loss)*0.02, ['+ ' int2str((loss(4)-loss(2))/loss(2)*100) '%'], 'color','w','HorizontalAlignment','center','VerticalAlignment','top','fontsize',fontsize_);

%remove xlabels and ticks
set(gca,'xticklabel',[],'FontSize',10,'XTick',zeros(1,0));

%title
if return_period == 9999
    text   (1- stretch, max(loss)*1.2, {'Annual Expected Loss (AEL)'}, 'color','k','HorizontalAlignment','left','VerticalAlignment','top','FontWeight','bold','fontsize',fontsize_);
 else
    text   (1- stretch, max(loss)*1.2, {'Expected loss with a return period of ' int2str(return_period) ' years'}, 'color','k','HorizontalAlignment','left','VerticalAlignment','top','FontWeight','bold','fontsize',fontsize_);
end

%xlabels
text   (1- stretch, loss(1)-max(loss)*0.02, {[num2str(climada_global.present_reference_year) ' today''s'];'expected loss'}, 'color','k','HorizontalAlignment','left','VerticalAlignment','top','fontsize',fontsize_);
text   (2- stretch, loss(1)-max(loss)*0.02, {'Incremental increase';'from economic';'gowth; no climate';'change'}, 'color','k','HorizontalAlignment','left','VerticalAlignment','top','fontsize',fontsize_);
text   (3- stretch, loss(1)-max(loss)*0.02, {'Incremental increase';'from climate change'}, 'color','k','HorizontalAlignment','left','VerticalAlignment','top','fontsize',fontsize_);
text   (4- stretch, loss(1)-max(loss)*0.02, {[num2str(climada_global.future_reference_year) ', total'];'expected loss'}, 'color','k','HorizontalAlignment','left','VerticalAlignment','top','fontsize',fontsize_);

%Legend
if length(ELS)>3
    L = legend([h(1),h(4),h(2),h(5),h(3),h(6)],[legend_str_new{1},legend_str_new{4},legend_str_new{2},legend_str_new{5},legend_str_new{3},legend_str_new{6}],'location','NorthOutside','fontsize',fontsize_);
    set(L,'Box', 'off')
   
else
    L = legend(h,[legend_str_new{1},legend_str_new{2},legend_str_new{3}],'location','NorthOutside','fontsize',fontsize_);
    set(L,'Box', 'off')
end


if isempty(check_printplot)
    choice = questdlg('print?','print');
    switch choice
    case 'Yes'
        check_printplot = 1;
    end
end

if check_printplot %(>=1)   
    print(fig,'-dpdf',[climada_global.data_dir foldername])
    %close
    fprintf('saved 1 FIGURE in folder %s \n', foldername);
end
    
return




