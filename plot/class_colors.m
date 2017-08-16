classdef class_colors
    % for setting default colors (color blind friendly)
    %   Usage:
    %       % Just to load the colors, use the following
    %       color_obj = class_colors();
    %
    %   Reference:
    %       < For choosing color blind friendly colors >
    %       http://mkweb.bcgsc.ca/colorblind/
    %       http://jfly.iam.u-tokyo.ac.jp/color/#see
    %
    %       < Tips for designing scientific figures for color blind
    %       readers>
    %       http://www.somersault1824.com/tips-for-designing-scientific-figures-for-color-blind-readers/
    %       
    %       A. Light & P.J. Bartlein, "The End of the Rainbow? Color Schemes for
    %       Improved Data Graphics," Eos,Vol. 85, No. 40, 5 October 2004.
    %       http://geography.uoregon.edu/datagraphics/EOS/Light&Bartlein_EOS2004.pdf
    %
    %       < Artistic colors >
    %       https://designschool.canva.com/blog/100-color-combinations/
    %
    %       < Deep learning based color selection >
    %       http://colormind.io/?utm_source=BetaList
    
    % Copyright (C) 2017 Sho Nakagome (snakagome@uh.edu)
    %
    %     This program is free software: you can redistribute it and/or modify
    %     it under the terms of the GNU General Public License as published by
    %     the Free Software Foundation, either version 3 of the License, or
    %     (at your option) any later version.
    %
    %     This program is distributed in the hope that it will be useful,
    %     but WITHOUT ANY WARRANTY; without even the implied warranty of
    %     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    %     GNU General Public License for more details.
    %
    %     You should have received a copy of the GNU General Public License
    %     along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    properties
        blind_friendly;
        artistic;
        gradient;
        N;
    end
    
    methods (Access = public)
        % defining a constructor
        function obj = class_colors(varargin)
            % color blind friendly colors
            obj.blind_friendly.color{1} = [230 159 0]./255; % Orange
            obj.blind_friendly.color{2} = [86 180 233]./255; % Sky blue
            obj.blind_friendly.color{3} = [0 158 115]./255; % Bluish Green
            obj.blind_friendly.color{4} = [240 228 66]./255; % Yellow
            obj.blind_friendly.color{5} = [0 114 178]./255; % Blue
            obj.blind_friendly.color{6} = [213 94 0]./255; % Vermillion
            obj.blind_friendly.color{7} = [204 121 167]./255; % Reddish Purple
            obj.blind_friendly.color{8} = [0 0 0]; % Black
            obj.blind_friendly.color{9} = [146 73 0]./255; % Brown
            obj.blind_friendly.color{10} = [73 0 146]./255; % Purple
            
            % artistic color combinations for 4 colors
                % 03. Dark & Earthy
                obj.artistic.dar{1} = [.275, .129, .102];
                obj.artistic.dar{2} = [.412, .239, .239];
                obj.artistic.dar{3} = [.729, .333, .212];
                obj.artistic.dar{4} = [.643, .22, .125];

                % 04. Crisp & Dramatic
                obj.artistic.crd{1} = [80/255, 81/255, 96/255];
                obj.artistic.crd{2} = [104/255, 130/255, 158/255];
                obj.artistic.crd{3} = [174/255, 189/255, 56/255];
                obj.artistic.crd{4} = [89/255, 130/255, 52/255];

                % 05. Cool Blues
                obj.artistic.cbl{1} = [0, .231, .275];
                obj.artistic.cbl{2} = [.027, .341, .357];
                obj.artistic.cbl{3} = [.4, .647, .678];
                obj.artistic.cbl{4} = [.769, .875, .902];

                % 07. Watery Blue-Greens
                obj.artistic.wbg{1} = [.008, .11, .118];
                obj.artistic.wbg{2} = [0, .267, .271];
                obj.artistic.wbg{3} = [.173, .471, .451];
                obj.artistic.wbg{4} = [.435, .725, .561];

                % 30. Berry Blues
                obj.artistic.bbs{1} = [.118, .122, .149];
                obj.artistic.bbs{2} = [.157, .212, .333];
                obj.artistic.bbs{3} = [.302, .392, .553];
                obj.artistic.bbs{4} = [.816, .882, .976];
                
            % gradient colormap for topoplots and spectrograms
            obj.N = get_varargin(varargin,'N',256);
            b2rColMap = [144 100  44;
                187 120  54;
                225 146  65;
                248 184 139;
                244 218 200;
                255 255 255;
                255 255 255;
                241 244 245;
                207 226 240;
                160 190 225;
                109 153 206;
                70  99 174;
                24  79 162]./255;
            index1 = linspace(0,1,size(b2rColMap,1));
            index2 = linspace(0,1,obj.N);
            interp_colmap = interp1(index1,b2rColMap,index2);
            obj.gradient.colormap = flipud(interp_colmap);
        end
    end
    
    methods (Static)
        % if you want to see the colors
        % give cell format colors as input
        function showcolors(cell_format_colors)
            % calculate how many colors are there
            n = length(cell_format_colors);
            % use loop to plot all
            figure;
            for col = 1:n
                rectangle('Position',[col,1,1,1],'FaceColor',cell_format_colors{col});
            end
        end
    end
    
    methods (Access = private)
        % defining a destructor
        function delete(obj)
            % Delete object
        end
    end
    
end

