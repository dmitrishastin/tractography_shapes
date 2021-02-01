classdef parsed_params
    
   properties %defaults       
       
        vox_size    = 0.625;
        verbose     = 0;
        temp_folder
        old_dir
    
   end
   
   methods
       
        function this = parsed_params(vol_file, parsed_input)
            
            %create a temp folder
            this.temp_folder = fileparts(vol_file); 

            skip = 0;

            for i = 1:numel(parsed_input)

                if skip
                    skip = 0;
                    continue
                end

                % for input providing external files - make sure the path recorded is full
                switch parsed_input{i}

                    % those with 'value' pair
                    case {'vox_size', 'temp_folder'}
                        eval(['this.' parsed_input{i} ' = parsed_input{i+1};']);
                        skip = 1;                                                                     

                    % those with no 'value' pair (booleans)
                    case 'verbose'
                        eval(['this.' parsed_input{i} ' = true;']);

                    otherwise
                        error('wrong arguments provided')

                end
            end
            
            if strcmp(class(this.vox_size), 'char')
                this.vox_size = str2num(this.vox_size);
            end

            this.temp_folder = [ this.temp_folder filesep num2str(round(rand * 10 ^ 15)) ];

            if ~exist(this.temp_folder,'dir')
                mkdir(this.temp_folder);
            end

            this.old_dir = cd(this.temp_folder);
    
        end
        
   end
    
end
